// lib/services/chat_list_service.dart

import '../mock/mock_chat_list_data_source.dart';
import '../models/chat_conversation.dart';
import '../models/trip_invitation.dart';
import 'account_service.dart';
import 'group_chat_service.dart';

class ChatListService {
  ChatListService({ChatListMockDataSource? dataSource})
      : _dataSource = dataSource ?? ChatListMockDataSource();

  final ChatListMockDataSource _dataSource;
  final GroupChatService _groupChatService = GroupChatService();
  final AccountService _accountService = AccountService();

  Future<List<ChatConversation>> getConversations() async {
    final list = await _dataSource.fetchConversations();
    final account = await _accountService.getCurrentUser();
    final readerId = account?.userId.trim().isNotEmpty == true
        ? account!.userId.trim()
        : 'signed_out';
    return Future.wait(
      list.map((json) async {
        final groupId = json['groupId'] as String;
        final members = await _groupChatService.getGroupMembers(groupId);
        final senderId = members
                .where((member) => member.isMe)
                .firstOrNull
                ?.id ??
            'user_me';
        final unreadCount = await _groupChatService.getUnreadMessageCount(
          groupId: groupId,
          readerId: readerId,
          senderId: senderId,
        );
        return ChatConversation.fromJson({...json, 'unreadCount': unreadCount});
      }),
    );
  }

  Future<List<TripInvitation>> getPendingInvitations() async {
    final list = await _dataSource.fetchInvitations();
    return list.map((json) => TripInvitation.fromJson(json)).toList();
  }

  Future<bool> acceptInvitation(String invitationId) {
    return _dataSource.acceptInvitation(invitationId);
  }

  Future<bool> declineInvitation(String invitationId) {
    return _dataSource.declineInvitation(invitationId);
  }
}
