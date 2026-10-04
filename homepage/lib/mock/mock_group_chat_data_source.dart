// group_chat_raw_data_source.dart
import '../mock/mock_group_chat.dart';

class GroupChatRawDataSource {
  Future<List<Map<String, dynamic>>> fetchRawMessages(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<dynamic> list = mockGroupChatData['messages'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> generateRawMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String text,
    String type = 'text',
    String? attachmentUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      'attachmentUrl': attachmentUrl,
      'isAiResponse': false,
    };
  }

  Future<Map<String, dynamic>> generateRawAiResponse(String prompt) async {
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

    return {
      'id': 'ai_msg_${DateTime.now().millisecondsSinceEpoch}',
      'senderId': 'ai_planner',
      'senderName': 'AI PLANNER • LIVE',
      'text': responseText,
      'timestamp': DateTime.now().toIso8601String(),
      'type': cardPayload != null ? 'aiRecommendationCard' : 'text',
      'isAiResponse': true,
      'cardPayload': cardPayload,
    };
  }

  Future<List<Map<String, dynamic>>> fetchRawPolls(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final List<dynamic> list = mockGroupChatData['polls'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}