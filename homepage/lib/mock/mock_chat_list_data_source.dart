// lib/mock/mock_chat_list_data_source.dart
//
// Simulates the backend for the chat list and invitations. Replace with an
// API-client call when the backend exists.

import 'mock_chat_list.dart';

class ChatListMockDataSource {
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final list = mockChatListData['conversations'] as List<dynamic>? ?? const [];
    return list
        .map((json) => Map<String, dynamic>.from(json as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchInvitations() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final list = mockChatListData['invitations'] as List<dynamic>? ?? const [];
    return list
        .map((json) => Map<String, dynamic>.from(json as Map))
        .toList();
  }

  Future<bool> acceptInvitation(String invitationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final invitations = List<dynamic>.from(
      mockChatListData['invitations'] as List<dynamic>? ?? const [],
    );

    final acceptedEntry = invitations.cast<Map<String, dynamic>>().firstWhere(
      (entry) => entry['id'] == invitationId,
      orElse: () => <String, dynamic>{},
    );

    final changed = acceptedEntry.isNotEmpty;
    if (changed) {
      final groupId = acceptedEntry['groupId'] as String? ?? '';
      final conversations = List<dynamic>.from(
        mockChatListData['conversations'] as List<dynamic>? ?? const [],
      );

      if (groupId.isNotEmpty &&
          !conversations.any(
            (entry) => (entry as Map<String, dynamic>)['groupId'] == groupId,
          )) {
        conversations.insert(0, {
          'groupId': groupId,
          'title': acceptedEntry['tripTitle'] as String? ?? 'Trip Chat',
          'destination': acceptedEntry['destination'] as String? ?? '',
          'lastMessage': 'Welcome to the group chat.',
          'lastMessageTime': DateTime.now().toUtc().toIso8601String(),
          'unreadCount': 0,
          'avatarUrl': acceptedEntry['hostAvatar'] as String? ?? '',
          'isLiveSync': true,
        });
        mockChatListData['conversations'] = conversations;
      }

      final filtered = invitations.where(
        (entry) => (entry as Map<String, dynamic>)['id'] != invitationId,
      ).toList();

      mockChatListData['invitations'] = filtered;
    }

    return changed;
  }

  Future<bool> declineInvitation(String invitationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final invitations = List<dynamic>.from(
      mockChatListData['invitations'] as List<dynamic>? ?? const [],
    );
    final filtered = invitations.where(
      (entry) => (entry as Map<String, dynamic>)['id'] != invitationId,
    ).toList();

    final changed = filtered.length != invitations.length;
    mockChatListData['invitations'] = filtered;
    return changed;
  }
}