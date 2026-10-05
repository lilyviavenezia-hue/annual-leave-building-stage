// lib/services/group_chat_service.dart

import '../mock/mock_group_chat_data_source.dart';
import '../models/chat_message.dart';
import '../models/group_member.dart';
import '../models/group_poll.dart';
import 'group_summary_service.dart';

class GroupChatService {
  GroupChatService({GroupChatMockDataSource? dataSource})
      : _dataSource = dataSource ?? GroupChatMockDataSource();

  final GroupChatMockDataSource _dataSource;
  final GroupSummaryService _summaryService = GroupSummaryService();

  Future<List<ChatMessage>> getChatMessages(String groupId) async {
    final rawMessages = await _dataSource.fetchMessages(groupId);
    final members = await _summaryService.getGroupMembers(groupId);
    final membersById = {for (final member in members) member.id: member};

    return rawMessages.map((json) {
      final member = membersById[json['senderId']];
      return ChatMessage.fromJson({
        ...json,
        if (member != null) 'senderName': member.name,
        if (member != null) 'senderAvatar': member.avatarUrl,
      });
    }).toList();
  }

  Future<List<GroupPoll>> getActivePolls(String groupId) async {
    final rawPolls = await _dataSource.fetchPolls(groupId);
    return rawPolls
        .map((json) => GroupPoll.fromJson(json))
        .where((poll) => !poll.isClosed)
        .toList();
  }

  Future<GroupPoll> addPoll(String groupId, GroupPoll poll) async {
    await _dataSource.savePoll(groupId, poll.toJson());
    return poll;
  }

  Future<bool> addGroupMember(dynamic groupIdOrMember, [GroupMember? maybeMember]) {
    if (groupIdOrMember is GroupMember) {
      return _summaryService.addGroupMember('group_kyoto_1', groupIdOrMember);
    }

    final groupId = groupIdOrMember as String;
    final member = maybeMember ??
        (throw ArgumentError.value(
          groupIdOrMember,
          'member',
          'A member must be provided when adding a group member.',
        ));
    return _summaryService.addGroupMember(groupId, member);
  }

  Future<bool> removeGroupMember({
    required String groupId,
    required String requesterId,
    required String memberId,
  }) async {
    final removed = await _summaryService.removeGroupMember(
      groupId: groupId,
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
  }) async {
    final json = await _dataSource.createMessage(
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      text: text,
      type: type.name,
      attachmentUrl: attachmentUrl,
    );
    return ChatMessage.fromJson(json);
  }

  Future<ChatMessage> triggerAiResponse(String promptText) async {
    final json = await _dataSource.createAiResponse(promptText);
    return ChatMessage.fromJson(json);
  }

  Future<GroupPoll> votePoll({
    required String groupId,
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    final json = await _dataSource.toggleVote(
      groupId: groupId,
      pollId: pollId,
      optionId: optionId,
      userId: userId,
    );
    return GroupPoll.fromJson(json);
  }
}