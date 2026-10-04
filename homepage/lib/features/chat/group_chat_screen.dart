import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import '../../models/collaborator.dart';
import '../../models/group_member.dart';
import '../../models/group_poll.dart';
import '../../models/group_trip_summary.dart';
import '../../services/group_chat_service.dart';
import '../../services/group_summary_service.dart';
import '../chat/trip_summary_screen.dart';
import '../trip_planning/trip_collaborators_screen.dart';
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

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final GroupChatService _chatService = GroupChatService();
  final GroupSummaryService _summaryService = GroupSummaryService();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  List<GroupPoll> _activePolls = [];
  List<GroupMember> _groupMembers = [];
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
    final polls = await _chatService.getActivePolls(widget.groupId);
    final summary = await _summaryService.getTripSummary(widget.groupId);
    final members = await _summaryService.getGroupMembers(widget.groupId);

    if (mounted) {
      setState(() {
        _messages = messages;
        _activePolls = polls;
        _tripSummary = summary;
        _groupMembers = members;
        _isLoading = false;
      });
      _scrollToBottom();
    }
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
    if (newMembers.isEmpty) return;
    setState(() => _groupMembers.addAll(newMembers));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${newMembers.length} ${newMembers.length == 1 ? 'member' : 'members'} added to the trip.',
        ),
      ),
    );
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
          _activePolls[index] = updatedPoll;
        }
      });
    }
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
      builder: (_) => CreatePollModal(
        onPollCreated: (poll) => Navigator.pop(context, poll),
      ),
    );

    if (createdPoll == null || !mounted) return;

    setState(() {
      _activePolls.add(createdPoll);
    });
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

  @override
  Widget build(BuildContext context) {
    final title = _tripSummary?.title ?? 'Group Chat';
    final travelers =
        _tripSummary?.confirmedDetails['Traveller'] ??
        _tripSummary?.confirmedDetails['Travelers'];
    final subtitle = travelers != null && travelers.isNotEmpty
        ? '$travelers Live Sync'
        : 'Live Sync';

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
                        onVote: _handleVote,
                      ),

                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return ChatMessageBubble(
                            message: _messages[index],
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
