// lib/mock/mock_group_summary_data_source.dart
//
// Simulates the backend for group summaries and members. Returns raw JSON.
// When the real backend exists, replace this class with an API-client call.

import 'mock_trip_summary.dart';

class GroupSummaryMockDataSource {
  Future<Map<String, dynamic>> fetchGroup(String groupId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return mockTripSummaryDatabase[groupId] ??
        <String, dynamic>{
          'summary': {
            'id': groupId,
            'title': 'New Trip',
            'confirmedDetails': {},
          },
          'members': [],
          'suggestions': [],
        };
  }

  /// Applies [changes] to every matching member. When [groupId] is null the
  /// member is updated in all groups.
  Future<bool> updateMember({
    String? groupId,
    required String memberId,
    required Map<String, dynamic> changes,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final targets = <String>[];
    if (groupId != null && mockTripSummaryDatabase.containsKey(groupId)) {
      targets.add(groupId);
    } else if (groupId == null) {
      targets.addAll(mockTripSummaryDatabase.keys);
    }

    var changed = false;
    for (final id in targets) {
      final members = List<dynamic>.from(
        mockTripSummaryDatabase[id]?['members'] as List<dynamic>? ??
            const <dynamic>[],
      );
      for (var index = 0; index < members.length; index++) {
        final member = members[index];
        if (member is! Map<String, dynamic> || member['id'] != memberId) {
          continue;
        }

        final updated = Map<String, dynamic>.from(member);
        updated.addAll(changes.map((key, value) => MapEntry(key, value)));
        members[index] = updated;
        changed = true;
      }
      mockTripSummaryDatabase[id]!['members'] = members;
    }
    return changed;
  }

  Future<bool> updateSuggestionSaved({
    required String groupId,
    required String suggestionId,
    required bool isSaved,
  }) {
    final suggestions =
        mockTripSummaryDatabase[groupId]?['suggestions'] as List<dynamic>?;
    if (suggestions == null) return Future.value(false);

    final suggestion = suggestions.where(
      (entry) => (entry as Map<String, dynamic>)['id'] == suggestionId,
    );
    if (suggestion.isEmpty) return Future.value(false);

    (suggestion.first as Map<String, dynamic>)['isSaved'] = isSaved;
    return Future.value(true);
  }

  Future<bool> addMember(
    String groupId,
    Map<String, dynamic> memberJson,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final group = mockTripSummaryDatabase.putIfAbsent(
      groupId,
      () => {'summary': {}, 'members': [], 'suggestions': []},
    );
    final members = List<dynamic>.from(group['members'] as List? ?? const []);
    if (members.any((entry) => (entry as Map)['id'] == memberJson['id'])) {
      return false; // Member already exists
    }

    members.add(Map<String, dynamic>.from(memberJson));
    group['members'] = members;
    return true;
  }

  Future<bool> removeMember({
    required String groupId,
    required String requesterId,
    required String memberId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final members =
        mockTripSummaryDatabase[groupId]?['members'] as List<dynamic>?;
    if (members == null) return false;

    final requesterIsHost = members.any(
      (entry) => entry['id'] == requesterId && entry['role'] == 'Host',
    );
    if (!requesterIsHost) return false;

    final index = members.indexWhere(
      (entry) =>
          entry['id'] == memberId &&
          entry['isMe'] != true &&
          entry['role'] != 'Host',
    );
    if (index == -1) return false;

    members.removeAt(index);
    return true;
  }

  /// Stand-in for the backend creating a group when an invitation is accepted.
  Future<void> createGroupFromInvitation({
    required String groupId,
    required String title,
    required String destination,
    required String dates,
    required String hostName,
    String? hostAvatar,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (mockTripSummaryDatabase.containsKey(groupId)) return;

    mockTripSummaryDatabase[groupId] = {
      'summary': {
        'id': 'sum_$groupId',
        'title': title,
        'destination': destination,
        'status': 'Planning',
        'dates': dates,
        'confirmedDetails': <String, String>{},
        'completedItems': 0,
        'totalItems': 7,
        'pendingDecisions': ['Budget', 'Accommodation', 'Transport'],
      },
      'members': [
        {
          'id': 'host_$groupId',
          'name': hostName,
          'avatarUrl': hostAvatar,
          'role': 'Host',
          'isMe': false,
          'minBudget': 1000,
          'maxBudget': 5000,
          'preferences': <String>[],
          'dateRange': dates,
        },
        {
          'id': 'user_me',
          'name': 'You',
          'role': 'Member',
          'isMe': true,
          'minBudget': 1000,
          'maxBudget': 5000,
          'preferences': <String>[],
          'dateRange': dates,
        },
      ],
      'suggestions': <Map<String, dynamic>>[],
    };
  }
}