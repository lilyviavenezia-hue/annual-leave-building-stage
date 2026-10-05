import 'package:flutter_test/flutter_test.dart';
import 'package:homempage/models/group_member.dart';
import 'package:homempage/models/group_poll.dart';
import 'package:homempage/models/leave_status.dart';
import 'package:homempage/services/collaborator_service.dart';
import 'package:homempage/services/group_chat_service.dart';
import 'package:homempage/services/group_summary_service.dart';
import 'package:homempage/services/leave_service.dart';

void main() {
  test(
    'five-person roster shares collaborator profiles and bundled avatars',
    () async {
      final collaborators = await CollaboratorService().getCollaborators();
      final members = await GroupSummaryService().getGroupMembers(
        'group_kyoto_1',
      );

      expect(members, hasLength(5));
      final membersById = {for (final member in members) member.id: member};
      for (final collaborator in collaborators) {
        final member = membersById[collaborator.id];
        expect(member, isNotNull);
        expect(member!.name, collaborator.name);
        expect(member.avatarUrl, collaborator.avatarUrl);
        expect(member.avatarUrl, startsWith('assets/avatars/'));
      }
    },
  );

  test('chat sender names and avatars match the group roster', () async {
    final members = await GroupSummaryService().getGroupMembers(
      'group_kyoto_1',
    );
    final messages = await GroupChatService().getChatMessages('group_kyoto_1');
    final membersById = {for (final member in members) member.id: member};

    for (final message in messages) {
      final member = membersById[message.senderId];
      if (member == null) continue;

      expect(message.senderName, member.name);
      expect(message.senderAvatar, member.avatarUrl);
    }
  });

  test('trip summary count follows member additions and removals', () async {
    final chatService = GroupChatService();
    final summaryService = GroupSummaryService();
    final member = GroupMember(
      id: 'test_member_count',
      name: 'Test Member',
      leaveBalanceSummary: '12 Days Available',
    );

    expect(await summaryService.getGroupMemberCount('group_kyoto_1'), 5);
    expect(
      (await summaryService.getTripSummary('group_kyoto_1'))
          .confirmedDetails['Traveller'],
      '5 Friends',
    );

    expect(await chatService.addGroupMember(member), isTrue);
    expect(await summaryService.getGroupMemberCount('group_kyoto_1'), 6);
    expect(
      (await summaryService.getTripSummary('group_kyoto_1'))
          .confirmedDetails['Traveller'],
      '6 Friends',
    );

    expect(
      await chatService.removeGroupMember(
        groupId: 'group_kyoto_1',
        requesterId: 'user_me',
        memberId: member.id,
      ),
      isTrue,
    );
    expect(await summaryService.getGroupMemberCount('group_kyoto_1'), 5);
  });

  test(
    'poll creation and votes persist with voter IDs as the count source',
    () async {
      final chatService = GroupChatService();
      final pollId = 'test_poll_${DateTime.now().microsecondsSinceEpoch}';
      final poll = GroupPoll(
        id: pollId,
        question: 'Test poll',
        allowMultipleAnswers: false,
        options: [
          PollOption(id: 'first', text: 'First'),
          PollOption(id: 'second', text: 'Second'),
        ],
      );

      await chatService.addPoll('group_kyoto_1', poll);
      var activePolls = await chatService.getActivePolls('group_kyoto_1');
      expect(activePolls.any((activePoll) => activePoll.id == pollId), isTrue);

      final updatedPoll = await chatService.votePoll(
        groupId: 'group_kyoto_1',
        pollId: pollId,
        optionId: 'first',
        userId: 'collab_1',
      );
      expect(updatedPoll.options.first.votedUserIds, ['collab_1']);
      expect(updatedPoll.options.first.voteCount, 1);

      final cancelledPoll = await chatService.votePoll(
        groupId: 'group_kyoto_1',
        pollId: pollId,
        optionId: 'first',
        userId: 'collab_1',
      );
      expect(cancelledPoll.options.first.votedUserIds, isEmpty);
      expect(cancelledPoll.options.first.voteCount, 0);

      final reVotedPoll = await chatService.votePoll(
        groupId: 'group_kyoto_1',
        pollId: pollId,
        optionId: 'first',
        userId: 'collab_1',
      );
      expect(reVotedPoll.options.first.votedUserIds, ['collab_1']);
      expect(reVotedPoll.options.first.voteCount, 1);

      await chatService.votePoll(
        groupId: 'group_kyoto_1',
        pollId: pollId,
        optionId: 'second',
        userId: 'collab_1',
      );
      activePolls = await chatService.getActivePolls('group_kyoto_1');
      final persistedPoll = activePolls.firstWhere((item) => item.id == pollId);
      expect(persistedPoll.options.first.votedUserIds, isEmpty);
      expect(persistedPoll.options.last.votedUserIds, ['collab_1']);

      final temporaryMember = GroupMember(
        id: 'test_poll_member',
        name: 'Temporary Member',
        leaveBalanceSummary: '12 Days Available',
      );
      await chatService.addGroupMember(temporaryMember);
      await chatService.votePoll(
        groupId: 'group_kyoto_1',
        pollId: pollId,
        optionId: 'first',
        userId: temporaryMember.id,
      );
      await chatService.removeGroupMember(
        groupId: 'group_kyoto_1',
        requesterId: 'user_me',
        memberId: temporaryMember.id,
      );

      activePolls = await chatService.getActivePolls('group_kyoto_1');
      final pollAfterRemoval = activePolls.firstWhere(
        (item) => item.id == pollId,
      );
      expect(
        pollAfterRemoval.options.every(
          (option) => !option.votedUserIds.contains(temporaryMember.id),
        ),
        isTrue,
      );
    },
  );

  test('sent messages use the current timestamp', () async {
    final beforeSend = DateTime.now();
    final message = await GroupChatService().sendMessage(
      groupId: 'group_kyoto_1',
      senderId: 'user_me',
      senderName: 'Ying',
      text: 'Current timestamp',
    );
    final afterSend = DateTime.now();

    expect(
      message.timestamp.isAfter(
        beforeSend.subtract(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    expect(
      message.timestamp.isBefore(afterSend.add(const Duration(seconds: 1))),
      isTrue,
    );
  });

  test('leave optimizer updates are shared through LeaveService', () async {
    final leaveService = LeaveService();
    final dateKey = '${DateTime.now().year}-12-31';
    final originalData = await leaveService.getUserLeaveData();
    final originalBalance = originalData.leaveBalance;

    await leaveService.updateDateStatus(dateKey, DateStatus.annualLeave);
    var updatedData = await leaveService.getUserLeaveData(
      year: DateTime.now().year,
    );
    expect(updatedData.dateStatuses[dateKey], DateStatus.annualLeave);

    await leaveService.updateLeaveBalance(originalBalance + 1);
    updatedData = await leaveService.getUserLeaveData();
    expect(updatedData.leaveBalance, originalBalance + 1);

    await leaveService.updateDateStatus(dateKey, DateStatus.normal);
    await leaveService.updateLeaveBalance(originalBalance);
  });

  test('only a host can remove a trip member', () async {
    final chatService = GroupChatService();
    expect(
      await chatService.removeGroupMember(
        groupId: 'group_kyoto_1',
        requesterId: 'collab_1',
        memberId: 'collab_2',
      ),
      isFalse,
    );
    expect(
      (await chatService.getGroupMembers('group_kyoto_1'))
          .any((member) => member.id == 'collab_2'),
      isTrue,
    );
  });
}
