// lib/services/chat_list_service.dart

import '../mock/mock_chat_list.dart';
import '../models/chat_conversation.dart';
import '../models/trip_invitation.dart';

class ChatListService {
  Future<List<ChatConversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<dynamic> list =
        mockChatListData['conversations'] as List<dynamic>;
    return list
        .map((json) => ChatConversation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<TripInvitation>> getPendingInvitations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final List<dynamic> list = mockChatListData['invitations'] as List<dynamic>;
    return list
        .map((json) => TripInvitation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<bool> acceptInvitation(String invitationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final invitations = mockChatListData['invitations'] as List<dynamic>;
    final invitationIndex = invitations.indexWhere(
      (invitation) =>
          (invitation as Map<String, dynamic>)['id'] == invitationId,
    );
    if (invitationIndex == -1) return false;

    final invitation = invitations[invitationIndex] as Map<String, dynamic>;
    final conversations = mockChatListData['conversations'] as List<dynamic>;
    final groupId = 'group_${invitation['id']}';
    if (!conversations.any(
      (conversation) =>
          (conversation as Map<String, dynamic>)['groupId'] == groupId,
    )) {
      final conversation = <String, Object>{
        'groupId': groupId,
        'title': invitation['tripTitle'] as String,
        'destination': invitation['destination'] as String,
        'lastMessage': 'You joined the trip',
        'lastMessageTime': DateTime.now().toUtc().toIso8601String(),
        'unreadCount': 0,
        'avatarUrl': invitation['hostAvatar'] as String? ?? '',
        'isLiveSync': true,
      };
      conversations.insert(0, conversation);
    }
    invitations.removeAt(invitationIndex);
    return true;
  }

  Future<bool> declineInvitation(String invitationId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    (mockChatListData['invitations'] as List<dynamic>).removeWhere(
      (inv) => inv['id'] == invitationId,
    );
    return true;
  }
}
