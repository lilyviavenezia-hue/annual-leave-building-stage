//with mock
import '../mock/mock_group_chat.dart';
import '../models/chat_message.dart';
import '../models/group_member.dart';
import '../models/group_poll.dart';
import 'group_summary_service.dart';

/// Handles simulated networking, delayed responses, and local mock transformations.
class GroupChatMockDataSource {
  final GroupSummaryService _summaryService = GroupSummaryService();

  Future<List<ChatMessage>> fetchChatMessages(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<dynamic> list = mockGroupChatData['messages'] as List<dynamic>;
    final members = await _summaryService.getGroupMembers(groupId);
    final membersById = {for (final member in members) member.id: member};

    return list.map((rawMessage) {
      final json = rawMessage as Map<String, dynamic>;
      final member = membersById[json['senderId']];
      return ChatMessage.fromJson({
        ...json,
        if (member != null) 'senderName': member.name,
        if (member != null) 'senderAvatar': member.avatarUrl,
      });
    }).toList();
  }

  Future<ChatMessage> generateMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String text,
    MessageType type = MessageType.text,
    String? attachmentUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      text: text,
      timestamp: DateTime.now(),
      type: type,
      attachmentUrl: attachmentUrl,
      isAiResponse: false,
    );
  }

  Future<ChatMessage> generateAiResponse(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 600));

    String responseText =
        "Here is what I found for '$prompt': Kyoto has amazing seasonal views and historic temples!";
    Map<String, dynamic>? cardPayload;

    final lowerPrompt = prompt.toLowerCase();
    if (lowerPrompt.contains('food') || lowerPrompt.contains('eat')) {
      responseText = "Based on your group's preferences, I recommend Nishiki Market for street food!";
      cardPayload = {
        'id': 'sug_3',
        'title': 'Nishiki Market',
        'location': 'Nakagyo, Kyoto',
        'category': 'FOOD • NIGHTLIFE',
        'matchPercentage': 82,
        'imageUrl': 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80',
      };
    } else if (lowerPrompt.contains('museum') ||
        lowerPrompt.contains('visit')) {
      responseText =
          "Ghibli Museum and Kiyomizu-dera are top matches for your group!";
      cardPayload = {
        'id': 'sug_1',
        'title': 'Kiyomizu-dera',
        'location': 'Higashiyama, Kyoto',
        'category': 'GROUP MATCH',
        'matchPercentage': 94,
        'imageUrl': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80',
      };
    }

    return ChatMessage(
      id: 'ai_msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'ai_planner',
      senderName: 'AI PLANNER • LIVE',
      text: responseText,
      timestamp: DateTime.now(),
      type: cardPayload != null
          ? MessageType.aiRecommendationCard
          : MessageType.text,
      isAiResponse: true,
      cardPayload: cardPayload,
    );
  }

  Future<List<GroupPoll>> fetchActivePolls(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final List<dynamic> list = mockGroupChatData['polls'] as List<dynamic>;
    return list
        .map((json) => GroupPoll.fromJson(json as Map<String, dynamic>))
        .where((poll) => !poll.isClosed)
        .toList();
  }

  Future<GroupPoll> createPoll(String groupId, GroupPoll poll) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final polls = mockGroupChatData['polls'] as List<dynamic>;
    polls.removeWhere(
      (entry) => (entry as Map<String, dynamic>)['id'] == poll.id,
    );
    polls.add(poll.toJson());
    return poll;
  }

  Future<GroupPoll> registerPollVote({
    required String groupId,
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final polls = (mockGroupChatData['polls'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final pollData = polls.firstWhere((poll) => poll['id'] == pollId);
    final options = (pollData['options'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final allowMultipleAnswers =
        pollData['allowMultipleAnswers'] as bool? ?? true;
    final selectedOption = options.firstWhere(
      (option) => option['id'] == optionId,
    );
    final selectedVoterIds =
        (selectedOption['votedUserIds'] as List<dynamic>? ?? []).cast<String>();
    final isCancellingVote = selectedVoterIds.contains(userId);

    for (final option in options) {
      final voterIds = (option['votedUserIds'] as List<dynamic>? ?? [])
          .cast<String>()
          .toList();
      if (option['id'] == optionId && isCancellingVote) {
        voterIds.remove(userId);
      } else if (option['id'] == optionId && !voterIds.contains(userId)) {
        voterIds.add(userId);
      } else if (!isCancellingVote &&
          !allowMultipleAnswers &&
          option['id'] != optionId) {
        voterIds.remove(userId);
      }
      option['votedUserIds'] = voterIds;
      option['voteCount'] = voterIds.length;
    }

    return GroupPoll.fromJson(pollData);
  }

  Future<void> removeMemberVotes(String groupId, String memberId) async {
    final polls = (mockGroupChatData['polls'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final poll in polls) {
      final options = (poll['options'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final option in options) {
        final voterIds = (option['votedUserIds'] as List<dynamic>? ?? [])
            .cast<String>()
            .where((id) => id != memberId)
            .toList();
        option['votedUserIds'] = voterIds;
        option['voteCount'] = voterIds.length;
      }
    }
  }
}

class GroupChatService {
  final GroupChatMockDataSource _dataSource;
  final GroupSummaryService _summaryService = GroupSummaryService();

  GroupChatService({GroupChatMockDataSource? dataSource})
    : _dataSource = dataSource ?? GroupChatMockDataSource();

  Future<List<ChatMessage>> getChatMessages(String groupId) {
    return _dataSource.fetchChatMessages(groupId);
  }

  Future<List<GroupPoll>> getActivePolls(String groupId) {
    return _dataSource.fetchActivePolls(groupId);
  }

  Future<GroupPoll> addPoll(String groupId, GroupPoll poll) {
    return _dataSource.createPoll(groupId, poll);
  }

  Future<bool> addGroupMember(GroupMember member) {
    return _summaryService.addGroupMember(member);
  }

  Future<bool> removeGroupMember({
    required String groupId,
    required String requesterId,
    required String memberId,
  }) async {
    final removed = await _summaryService.removeGroupMember(
      requesterId: requesterId,
      memberId: memberId,
    );
    if (removed) await _dataSource.removeMemberVotes(groupId, memberId);
    return removed;
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) {
    return _summaryService.getGroupMembers(groupId);
  }

  Future<ChatMessage> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String text,
    MessageType type = MessageType.text,
    String? attachmentUrl,
  }) {
    return _dataSource.generateMessage(
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      text: text,
      type: type,
      attachmentUrl: attachmentUrl,
    );
  }

  Future<ChatMessage> triggerAiResponse(String promptText) {
    return _dataSource.generateAiResponse(promptText);
  }

  Future<GroupPoll> votePoll({
    required String groupId,
    required String pollId,
    required String optionId,
    required String userId,
  }) {
    return _dataSource.registerPollVote(
      groupId: groupId,
      pollId: pollId,
      optionId: optionId,
      userId: userId,
    );
  }
}
