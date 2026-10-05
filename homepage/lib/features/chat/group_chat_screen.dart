import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/collaborator.dart';
import '../../models/chat_message.dart';
import '../../models/account_profile.dart';
import '../../models/group_member.dart';
import '../../models/group_poll.dart';
import '../../models/group_trip_summary.dart';
import '../../services/account_service.dart';
import '../../services/group_chat_service.dart';
import '../../services/group_summary_service.dart';
import '../chat/trip_summary_screen.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/chat_input_field.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_summary_card.dart';
import 'widgets/group_members_drawer.dart';
import 'widgets/sticky_polls_section.dart';
import 'widgets/create_poll_modal.dart';
import 'widgets/upload_file_modal.dart';
import 'widgets/upload_media_modal.dart';
import 'receipt_scanner_screen.dart';
import '../trip_planning/trip_collaborators_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final GroupChatService _chatService = GroupChatService();
  final AccountService _accountService = AccountService();
  final GroupSummaryService _summaryService = GroupSummaryService();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  List<GroupPoll> _activePolls = [];
  List<GroupMember> _groupMembers = [];
  AccountProfile? _currentUserProfile;
  GroupTripSummary? _tripSummary;

  bool _isLoading = true;
  bool _isSending = false;
  bool _showSummaryCard = true;

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatData() async {
    final messages = await _chatService.getChatMessages(widget.groupId);
    final currentUser = await _accountService.getCurrentUser();
    final polls = await _chatService.getActivePolls(widget.groupId);
    final summary = await _summaryService.getTripSummary(widget.groupId);
    final members = await _summaryService.getGroupMembers(widget.groupId);

    if (mounted) {
      setState(() {
        _messages = messages;
        _currentUserProfile = currentUser;
        _activePolls = polls;
        _tripSummary = summary;
        _groupMembers = members;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _refreshGroupMembers() async {
    final members = await _summaryService.getGroupMembers(widget.groupId);
    if (!mounted) return;
    setState(() => _groupMembers = members);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);

    final newMessage = await _chatService.sendMessage(
      groupId: widget.groupId,
      senderId: 'user_me',
      senderName: 'You',
      senderAvatar: _currentUserProfile?.avatarUrl,
      text: text,
    );

    if (mounted) {
      setState(() {
        _messages.add(newMessage);
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _handleAskAi(String promptText) async {
    final aiMessage = await _chatService.triggerAiResponse(promptText);
    if (mounted) {
      setState(() {
        _messages.add(aiMessage);
      });
      _scrollToBottom();
    }
  }

  Future<void> _handleVote(String pollId, String optionId) async {
    final updatedPoll = await _chatService.votePoll(
      groupId: widget.groupId,
      pollId: pollId,
      optionId: optionId,
      userId: 'user_me',
    );

    if (mounted) {
      setState(() {
        final index = _activePolls.indexWhere((p) => p.id == pollId);
        if (index != -1) {
          updatedPoll.isExpanded = _activePolls[index].isExpanded;
          _activePolls[index] = updatedPoll;
        }
      });
    }
  }

  Future<void> _addGroupMembers() async {
    _scaffoldKey.currentState?.closeEndDrawer();
    final existingMemberIds = _groupMembers.map((member) => member.id).toSet();
    final selectedMembers = await Navigator.of(context)
        .push<List<Collaborator>>(
          MaterialPageRoute<List<Collaborator>>(
            builder: (_) => TripCollaboratorsScreen(
              startWithNoMembers: true,
              returnSelectedMembers: true,
              existingCollaboratorIds: existingMemberIds,
              screenTitle: 'Add trip members',
            ),
          ),
        );
    if (!mounted || selectedMembers == null || selectedMembers.isEmpty) return;

    final newMembers = selectedMembers
        .where(
          (collaborator) =>
              !_groupMembers.any((member) => member.id == collaborator.id),
        )
        .map(
          (collaborator) => GroupMember(
            id: collaborator.id,
            name: collaborator.name,
            avatarUrl: collaborator.avatarUrl,
            leaveBalanceSummary: '12 Days Available',
          ),
        )
        .toList();
    for (final member in newMembers) {
      await _chatService.addGroupMember(widget.groupId, member);
    }
    final updatedMembers = await _chatService.getGroupMembers(widget.groupId);
    final updatedSummary = await _summaryService.getTripSummary(widget.groupId);
    if (!mounted) return;

    setState(() {
      _groupMembers = updatedMembers;
      _tripSummary = updatedSummary;
    });
  }

  Future<void> _removeGroupMember(GroupMember member) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove trip member?'),
        content: Text('Remove ${member.name} from this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldRemove != true || !mounted) return;

    final requesterId = _groupMembers
        .where((groupMember) => groupMember.isMe)
        .firstOrNull
        ?.id;
    if (requesterId == null) return;

    final removed = await _chatService.removeGroupMember(
      groupId: widget.groupId,
      requesterId: requesterId,
      memberId: member.id,
    );
    if (!removed || !mounted) return;

    final members = await _chatService.getGroupMembers(widget.groupId);
    final summary = await _summaryService.getTripSummary(widget.groupId);
    final polls = await _chatService.getActivePolls(widget.groupId);
    if (!mounted) return;
    setState(() {
      _groupMembers = members;
      _tripSummary = summary;
      _activePolls = polls;
    });
  }

  void _navigateToTripSummary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripSummaryScreen(groupId: widget.groupId),
      ),
    );
  }

  Future<void> _openMediaUpload() async {
    final fileName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UploadMediaModal(
        onMediaSelected: (selected) => Navigator.pop(context, selected),
      ),
    );

    if (fileName == null || fileName.isEmpty || !mounted) return;

    final uploadedMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user_me',
      senderName: 'You',
      text: fileName,
      timestamp: DateTime.now(),
      type: MessageType.image,
      isAiResponse: false,
    );

    setState(() {
      _messages.add(uploadedMessage);
    });
    _scrollToBottom();
  }

  Future<void> _openFileUpload() async {
    final fileName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UploadFileModal(
        onFileSelected: (selected) => Navigator.pop(context, selected),
      ),
    );

    if (fileName == null || fileName.isEmpty || !mounted) return;

    final uploadedMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user_me',
      senderName: 'You',
      text: fileName,
      timestamp: DateTime.now(),
      type: MessageType.file,
      isAiResponse: false,
    );

    setState(() {
      _messages.add(uploadedMessage);
    });
    _scrollToBottom();
  }

  Future<void> _openCreatePoll() async {
    final createdPoll = await showModalBottomSheet<GroupPoll>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePollModal(),
    );

    if (createdPoll == null || !mounted) return;
    await _chatService.addPoll(widget.groupId, createdPoll);
    final updatedPolls = await _chatService.getActivePolls(widget.groupId);
    if (!mounted) return;

    setState(() => _activePolls = updatedPolls);
    _scrollToBottom();
  }

  void _navigateToExpenses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScannerScreen(groupId: widget.groupId),
      ),
    );
  }

  List<_ChatTimelineItem> _buildTimelineItems() {
    final messages = List<ChatMessage>.of(_messages)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final items = <_ChatTimelineItem>[];
    DateTime? previousDate;

    for (final message in messages) {
      final localTimestamp = message.timestamp.toLocal();
      final messageDate = DateTime(
        localTimestamp.year,
        localTimestamp.month,
        localTimestamp.day,
      );
      if (previousDate == null || !_isSameDate(previousDate, messageDate)) {
        items.add(_ChatTimelineItem.date(messageDate));
        previousDate = messageDate;
      }
      items.add(_ChatTimelineItem.message(message));
    }
    return items;
  }

  bool _isSameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (_isSameDate(date, today)) return 'Today';
    if (_isSameDate(date, yesterday)) return 'Yesterday';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = _tripSummary?.title ?? 'Group Chat';
    final subtitle = '${_groupMembers.length} Friends Live Sync';
    final timelineItems = _buildTimelineItems();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundWhite,
      appBar: GroupChatAppBar(
        title: title,
        subtitle: subtitle,
        onOpenMembers: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: GroupMembersDrawer(
        members: _groupMembers,
        onAddMemberPressed: _addGroupMembers,
        onRemoveMember: _removeGroupMember,
        onMemberUpdated: _refreshGroupMembers,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < -300) {
                  _scaffoldKey.currentState?.openEndDrawer();
                }
              },
              child: SafeArea(
                child: Column(
                  children: [
                    if (_tripSummary != null)
                      ChatSummaryCard(
                        tripSummary: _tripSummary!,
                        isExpanded: _showSummaryCard,
                        onTapCard: _navigateToTripSummary,
                        onToggleSummary: () {
                          setState(() {
                            _showSummaryCard = !_showSummaryCard;
                          });
                        },
                      ),

                    if (_activePolls.isNotEmpty)
                      StickyPollsSection(
                        activePolls: _activePolls,
                        members: _groupMembers,
                        onVote: _handleVote,
                      ),

                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: timelineItems.length,
                        itemBuilder: (context, index) {
                          final item = timelineItems[index];
                          if (item.date != null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  _formatDateLabel(item.date!),
                                  style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }
                          return ChatMessageBubble(
                            message: item.message!,
                            currentUserProfile: _currentUserProfile,
                            onAskAi: _handleAskAi,
                          );
                        },
                      ),
                    ),

                    ChatInputField(
                      controller: _messageController,
                      onSend: _handleSendMessage,
                      onMediaTap: _openMediaUpload,
                      onFileTap: _openFileUpload,
                      onPollTap: _openCreatePoll,
                      onExpensesTap: _navigateToExpenses,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ChatTimelineItem {
  const _ChatTimelineItem.date(this.date) : message = null;
  const _ChatTimelineItem.message(this.message) : date = null;

  final DateTime? date;
  final ChatMessage? message;
}
