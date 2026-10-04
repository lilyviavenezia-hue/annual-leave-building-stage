//with mock
import '../mock/mock_group_chat.dart';
import '../models/chat_message.dart';
import '../models/group_poll.dart';

/// Handles simulated networking, delayed responses, and local mock transformations.
class GroupChatMockDataSource {
  Future<List<ChatMessage>> fetchChatMessages(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<dynamic> list = mockGroupChatData['messages'] as List<dynamic>;
    return list.map((json) => ChatMessage.fromJson(json as Map<String, dynamic>)).toList();
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
      responseText =
          "Based on your group's preferences, I recommend Nishiki Market for street food!";
      cardPayload = {
        'id': 'sug_3',
        'title': 'Nishiki Market',
        'location': 'Nakagyo, Kyoto',
        'category': 'FOOD • NIGHTLIFE',
        'matchPercentage': 82,
        'imageUrl':
            'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=600&q=80',
      };
    } else if (lowerPrompt.contains('museum') || lowerPrompt.contains('visit')) {
      responseText =
          "Ghibli Museum and Kiyomizu-dera are top matches for your group!";
      cardPayload = {
        'id': 'sug_1',
        'title': 'Kiyomizu-dera',
        'location': 'Higashiyama, Kyoto',
        'category': 'GROUP MATCH',
        'matchPercentage': 94,
        'imageUrl':
            'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=600&q=80',
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
    return list.map((json) => GroupPoll.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<GroupPoll> registerPollVote({
    required String groupId,
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final polls = await fetchActivePolls(groupId);
    final poll = polls.firstWhere((p) => p.id == pollId);

    final updatedOptions = poll.options.map((opt) {
      if (opt.id == optionId) {
        final newVotedList = List<String>.from(opt.votedUserIds);
        if (!newVotedList.contains(userId)) {
          newVotedList.add(userId);
        }
        return PollOption(
          id: opt.id,
          text: opt.text,
          voteCount: newVotedList.length,
          votedUserIds: newVotedList,
        );
      }
      return opt;
    }).toList();

    return GroupPoll(
      id: poll.id,
      question: poll.question,
      allowMultipleAnswers: poll.allowMultipleAnswers,
      isExpanded: poll.isExpanded,
      isClosed: poll.isClosed,
      options: updatedOptions,
    );
  }
}

class GroupChatService {
  final GroupChatMockDataSource _dataSource;

  GroupChatService({GroupChatMockDataSource? dataSource})
      : _dataSource = dataSource ?? GroupChatMockDataSource();

  Future<List<ChatMessage>> getChatMessages(String groupId) {
    return _dataSource.fetchChatMessages(groupId);
  }

  Future<List<GroupPoll>> getActivePolls(String groupId) {
    return _dataSource.fetchActivePolls(groupId);
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