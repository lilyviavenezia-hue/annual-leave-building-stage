// lib/services/group_summary_service.dart

import '../mock/mock_group_summary_data_source.dart';
import '../models/group_member.dart';
import '../models/group_trip_summary.dart';
import 'account_service.dart';

class GroupSummaryService {
  GroupSummaryService({GroupSummaryMockDataSource? dataSource})
      : _dataSource = dataSource ?? GroupSummaryMockDataSource();

  final GroupSummaryMockDataSource _dataSource;
  final AccountService _accountService = AccountService();

  Future<GroupTripSummary> getTripSummary(String groupId) async {
    final groupData = await _dataSource.fetchGroup(groupId);
    final membersData =
        groupData['members'] as List<dynamic>? ?? const <dynamic>[];
    final summaryData = Map<String, dynamic>.from(
      groupData['summary'] as Map? ?? const <String, dynamic>{},
    );

    var minBudget = double.infinity;
    var maxBudget = 0.0;
    for (final item in membersData) {
      final member = item as Map<String, dynamic>;
      final memberMin = (member['minBudget'] as num? ?? 0).toDouble();
      final memberMax = (member['maxBudget'] as num? ?? 0).toDouble();
      if (memberMin < minBudget) minBudget = memberMin;
      if (memberMax > maxBudget) maxBudget = memberMax;
    }
    final actualMin = minBudget == double.infinity ? 0.0 : minBudget;
    final budgetRange = 'RM${actualMin.toInt()} - RM${maxBudget.toInt()}';

    final destination = (summaryData['destination'] as String?) ?? '';
    final dates = (summaryData['dates'] as String?) ?? '';
    final completedItems =
        (summaryData['completedItems'] as num?)?.toInt() ?? 0;
    final totalItems = (summaryData['totalItems'] as num?)?.toInt() ?? 0;
    final pendingDecisions =
        (summaryData['pendingDecisions'] as List<dynamic>? ??
                const <dynamic>[])
            .map((entry) => entry.toString())
            .toList();

    final preferenceTags = membersData
        .expand(
          (member) =>
              (member as Map<String, dynamic>)['preferences']
                  as List<dynamic>? ??
              const <dynamic>[],
        )
        .map((entry) => entry.toString())
        .toSet()
        .toList();

    final confirmedDetails = Map<String, String>.from(
      summaryData['confirmedDetails'] as Map? ?? {},
    )
      ..['Destination'] = destination.isNotEmpty ? destination : 'To be decided'
      ..['Dates'] = dates.isNotEmpty ? dates : 'To be decided'
      ..['Traveller'] = '${membersData.length} Friends'
      ..['Budget'] = budgetRange;

    return GroupTripSummary.fromJson({
      'groupId': groupId,
      'title': summaryData['title'] ?? 'New Trip',
      'dates': dates,
      'destination': destination,
      'budget': budgetRange,
      'progress': totalItems > 0 ? completedItems / totalItems : 0.0,
      'completedItems': completedItems,
      'totalItems': totalItems,
      'pendingDecisions': pendingDecisions,
      'confirmedDetails': confirmedDetails,
      'preferenceTags': preferenceTags,
      'isReadyToPlan': false,
    });
  }

  Future<List<GroupSuggestion>> getGroupSuggestions(String groupId) async {
    final groupData = await _dataSource.fetchGroup(groupId);
    final list = groupData['suggestions'] as List<dynamic>? ?? const <dynamic>[];
    return list
        .map((json) => GroupSuggestion.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<bool> setGroupSuggestionSaved({
    required String groupId,
    required String suggestionId,
    required bool isSaved,
  }) {
    return _dataSource.updateSuggestionSaved(
      groupId: groupId,
      suggestionId: suggestionId,
      isSaved: isSaved,
    );
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    final groupData = await _dataSource.fetchGroup(groupId);
    final profile = await _accountService.getCurrentUser();
    final list = groupData['members'] as List<dynamic>? ?? const <dynamic>[];

    return list.map((json) {
      final memberJson =
          Map<String, dynamic>.from(json as Map<String, dynamic>);
      // The group's own member list is the source of truth for everyone except
      // the signed-in user, whose avatar always follows their account profile.
      final isMe = memberJson['isMe'] as bool? ?? memberJson['id'] == 'user_me';
      if (isMe && profile != null && profile.avatarUrl.isNotEmpty) {
        memberJson['avatarUrl'] = profile.avatarUrl;
      }
      return GroupMember.fromJson(memberJson);
    }).toList();
  }

  Future<int> getGroupMemberCount(String groupId) async =>
      (await getGroupMembers(groupId)).length;

  Future<bool> updateMemberBudget({
    required String memberId,
    required double minBudget,
    required double maxBudget,
    String? groupId,
  }) {
    return _dataSource.updateMember(
      groupId: groupId,
      memberId: memberId,
      changes: {'minBudget': minBudget, 'maxBudget': maxBudget},
    );
  }

  Future<bool> updateMemberDateRange({
    required String memberId,
    required String dateRange,
    String? groupId,
  }) {
    return _dataSource.updateMember(
      groupId: groupId,
      memberId: memberId,
      changes: {'dateRange': dateRange},
    );
  }

  Future<bool> updateMemberPreferences({
    required String memberId,
    required List<String> preferences,
    String? groupId,
  }) {
    return _dataSource.updateMember(
      groupId: groupId,
      memberId: memberId,
      changes: {'preferences': List<String>.from(preferences)},
    );
  }

  Future<bool> addGroupMember(String groupId, GroupMember member) {
    return _dataSource.addMember(groupId, member.toJson());
  }

  Future<bool> removeGroupMember({
    required String groupId,
    required String requesterId,
    required String memberId,
  }) {
    return _dataSource.removeMember(
      groupId: groupId,
      requesterId: requesterId,
      memberId: memberId,
    );
  }
}