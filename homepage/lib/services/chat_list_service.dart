// lib/services/chat_list_service.dart

import '../mock/mock_chat_list_data_source.dart';
import '../models/chat_conversation.dart';
import '../models/trip_invitation.dart';

class ChatListService {
  ChatListService({ChatListMockDataSource? dataSource})
      : _dataSource = dataSource ?? ChatListMockDataSource();

  final ChatListMockDataSource _dataSource;

  Future<List<ChatConversation>> getConversations() async {
    final list = await _dataSource.fetchConversations();
    return list.map((json) => ChatConversation.fromJson(json)).toList();
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