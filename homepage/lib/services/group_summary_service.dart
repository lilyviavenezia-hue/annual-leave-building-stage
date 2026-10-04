import '../mock/mock_trip_summary.dart';
import '../models/group_member.dart';
import '../models/group_trip_summary.dart';

class GroupSummaryService {
  Future<GroupTripSummary> getTripSummary(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return GroupTripSummary.fromJson(mockTripSummaryData);
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
