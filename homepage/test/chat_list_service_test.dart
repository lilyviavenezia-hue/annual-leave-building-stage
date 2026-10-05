import 'package:flutter_test/flutter_test.dart';

import 'package:homempage/mock/mock_chat_list.dart';
import 'package:homempage/services/chat_list_service.dart';

void main() {
  test('accepting an invitation adds the exact accepted chat to active chats', () async {
    final originalInvitations = List<Map<String, dynamic>>.from(
      (mockChatListData['invitations'] as List<dynamic>? ?? const [])
          .map((json) => Map<String, dynamic>.from(json as Map)),
    );
    final originalConversations = List<Map<String, dynamic>>.from(
      (mockChatListData['conversations'] as List<dynamic>? ?? const [])
          .map((json) => Map<String, dynamic>.from(json as Map)),
    );

    addTearDown(() {
      mockChatListData['invitations'] = originalInvitations;
      mockChatListData['conversations'] = originalConversations;
    });

    mockChatListData['invitations'] = [
      {
        'id': 'inv_1',
        'groupId': 'group_tokyo_1',
        'hostName': 'Sarah Jenkins',
        'hostAvatar': 'https://i.pravatar.cc/150?img=5',
        'tripTitle': 'Tokyo Spring Blossom',
        'destination': 'Tokyo, Japan',
        'dates': '15 Apr - 22 Apr 2026',
      },
    ];
    mockChatListData['conversations'] = [
      {
        'groupId': 'group_kyoto_1',
        'title': 'Kyoto Autumn Getaway',
        'destination': 'Kyoto, Japan',
        'lastMessage': 'Kyoto is a historic Japanese city famous...',
        'lastMessageTime': '2026-10-12T14:39:00Z',
        'unreadCount': 2,
        'avatarUrl': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=300&q=80',
        'isLiveSync': true,
      },
    ];

    final service = ChatListService();

    final accepted = await service.acceptInvitation('inv_1');
    expect(accepted, isTrue);

    final activeChats = await service.getConversations();
    expect(activeChats.any((chat) => chat.groupId == 'group_tokyo_1'), isTrue);
    expect(
      (await service.getPendingInvitations()).any((inv) => inv.id == 'inv_1'),
      isFalse,
    );
  });
}
