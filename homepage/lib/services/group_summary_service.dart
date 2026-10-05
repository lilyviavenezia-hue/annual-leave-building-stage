import '../mock/mock_trip_summary.dart';
import '../models/group_member.dart';
import '../models/group_trip_summary.dart';

class GroupSummaryService {
  Future<GroupTripSummary> getTripSummary(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final memberCount = mockGroupMembersData.length;
    final minBudget = mockGroupMembersData.fold<double>(
      double.infinity,
      (value, item) => (item['minBudget'] as num).toDouble() < value
          ? (item['minBudget'] as num).toDouble()
          : value,
    );
    final maxBudget = mockGroupMembersData.fold<double>(
      0,
      (value, item) => (item['maxBudget'] as num).toDouble() > value
          ? (item['maxBudget'] as num).toDouble()
          : value,
    );
    final budgetRange = 'RM${minBudget.toInt()} - RM${maxBudget.toInt()}';
    final confirmedDetails = Map<String, String>.from(
      mockTripSummaryData['confirmedDetails'] as Map,
    )
      ..['Traveller'] = '$memberCount Friends'
      ..['Budget'] = budgetRange;

    return GroupTripSummary.fromJson({
      ...mockTripSummaryData,
      'budget': budgetRange,
      'confirmedDetails': confirmedDetails,
    });
  }

  Future<List<GroupSuggestion>> getGroupSuggestions(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return mockGroupSuggestionsData
        .map((json) => GroupSuggestion.fromJson(json))
        .toList();
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockGroupMembersData
        .map((json) => GroupMember.fromJson(json))
        .toList();
  }

  Future<int> getGroupMemberCount(String groupId) async =>
      (await getGroupMembers(groupId)).length;

  Future<bool> addGroupMember(GroupMember member) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (mockGroupMembersData.any((entry) => entry['id'] == member.id)) {
      return false;
    }
    mockGroupMembersData.add(member.toJson());
    return true;
  }

  Future<bool> removeGroupMember({
    required String requesterId,
    required String memberId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final requesterIsHost = mockGroupMembersData.any(
      (entry) => entry['id'] == requesterId && entry['role'] == 'Host',
    );
    if (!requesterIsHost) return false;

    final index = mockGroupMembersData.indexWhere(
      (entry) =>
          entry['id'] == memberId &&
          entry['isMe'] != true &&
          entry['role'] != 'Host',
    );
    if (index == -1) return false;
    mockGroupMembersData.removeAt(index);
    return true;
  }

  /// Updates budget range for a specific member in mock storage
  Future<bool> updateMemberBudget({
    required String memberId,
    required double minBudget,
    required double maxBudget,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = mockGroupMembersData.indexWhere((m) => m['id'] == memberId);
    if (index != -1) {
      mockGroupMembersData[index]['minBudget'] = minBudget;
      mockGroupMembersData[index]['maxBudget'] = maxBudget;
      return true;
    }
    return false;
  }

  Future<bool> updateMemberDateRange({
    required String memberId,
    required String dateRange,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = mockGroupMembersData.indexWhere((m) => m['id'] == memberId);
    if (index == -1) return false;
    mockGroupMembersData[index]['dateRange'] = dateRange;
    return true;
  }

  /// Updates preference tags for a specific member in mock storage
  Future<bool> updateMemberPreferences({
    required String memberId,
    required List<String> preferences,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = mockGroupMembersData.indexWhere((m) => m['id'] == memberId);
    if (index != -1) {
      mockGroupMembersData[index]['preferences'] = List.from(preferences);
      return true;
    }
    return false;
  }
}
