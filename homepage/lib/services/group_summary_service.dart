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

    final savedDetails = Map<String, String>.from(
      summaryData['confirmedDetails'] as Map? ?? const {},
    );
    final destination = (summaryData['destination'] as String?) ??
        savedDetails['Destination'] ?? '';
    final dates = (summaryData['dates'] as String?) ??
        savedDetails['Dates'] ?? '';
    final selections = await _dataSource.fetchPlanningSelections(groupId);
    final budgetRange = _formatTripBudget(
      summaryData['budgetRange'] ??
          summaryData['budget'] ??
          savedDetails['Budget'],
    );
    final completionStates = [
      selections['Accommodation']!.isNotEmpty,
      selections['Transport']!.isNotEmpty,
      destination.trim().isNotEmpty,
      dates.trim().isNotEmpty,
      membersData.isNotEmpty,
      budgetRange.isNotEmpty,
    ];
    final completedItems = completionStates.where((isComplete) => isComplete).length;
    final totalItems = completionStates.length;

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

    final confirmedDetails = <String, String>{
      'Accommodation': selections['Accommodation']!.isNotEmpty
          ? 'Selected'
          : 'Needs decision',
      'Transport': selections['Transport']!.isNotEmpty
          ? 'Selected'
          : 'Needs decision',
      'Destination': destination.isNotEmpty ? destination : 'To be decided',
      'Dates': dates.isNotEmpty ? dates : 'To be decided',
      'Traveller': '${membersData.length}',
      'Budget': budgetRange.isEmpty ? 'Needs decision' : budgetRange,
    };
    final pendingDecisions = confirmedDetails.entries
        .where((entry) => entry.value == 'Needs decision')
        .map((entry) => entry.key)
        .toList();

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

  String _formatTripBudget(dynamic rawBudget) {
    if (rawBudget is num) return 'RM${_formatAmount(rawBudget)}';
    if (rawBudget is Map) {
      final minimum = rawBudget['min'] as num?;
      final maximum = rawBudget['max'] as num?;
      if (minimum == null && maximum == null) return '';
      if (minimum == null || maximum == null || minimum == maximum) {
        return 'RM${_formatAmount(minimum ?? maximum!)}';
      }
      return 'RM${_formatAmount(minimum)}–RM${_formatAmount(maximum)}';
    }
    if (rawBudget is String) {
      final text = rawBudget.trim();
      if (text.isEmpty || text == 'Needs decision' || text == 'Selected') {
        return '';
      }
      final amounts = RegExp(r'\d[\d,]*(?:\.\d+)?')
          .allMatches(text)
          .map((match) => double.tryParse(match.group(0)!.replaceAll(',', '')))
          .whereType<double>()
          .toList();
      if (amounts.isEmpty) return '';
      if (amounts.length == 1) return 'RM${_formatAmount(amounts.first)}';
      return 'RM${_formatAmount(amounts[0])}–RM${_formatAmount(amounts[1])}';
    }
    return '';
  }

  String _formatAmount(num amount) {
    final value = amount.toDouble();
    final fixed = value == value.truncateToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return parts.length == 1 ? whole : '$whole.${parts.last}';
  }

  Future<Map<String, List<String>>> getPlanningSelections(String groupId) =>
      _dataSource.fetchPlanningSelections(groupId);

  Future<void> setPlanningOptionSelected({
    required String groupId,
    required String category,
    required String optionId,
    required bool selected,
  }) => _dataSource.setPlanningOptionSelected(
    groupId: groupId,
    category: category,
    optionId: optionId,
    selected: selected,
  );

  Future<void> updateConfirmedDetail({
    required String groupId,
    required String key,
    required String value,
  }) => _dataSource.updateConfirmedDetail(
    groupId: groupId,
    key: key,
    value: value,
  );

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
