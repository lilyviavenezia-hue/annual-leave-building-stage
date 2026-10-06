import '../models/leave_data.dart';
import '../models/leave_combo.dart';
import '../models/leave_status.dart';
import '../mock/mock_leave.dart';
import 'account_service.dart';

class LeaveService {
  static final Map<String, Map<String, dynamic>> _leaveDataByMemberId = {};

  Future<Map<String, dynamic>> _leaveDataForMember(String? memberId) async {
    final explicitId = memberId?.trim();
    final account = explicitId == null || explicitId.isEmpty
        ? await AccountService().getCurrentUser()
        : null;
    final accountId = account?.userId.trim();
    final key = explicitId != null && explicitId.isNotEmpty
        ? explicitId
        : accountId == null || accountId.isEmpty
        ? 'signed_out'
        : accountId;

    return _leaveDataByMemberId.putIfAbsent(key, () {
      final fixture = mockLeaveDataByMemberId[key] ??
          createMemberLeaveDataFallback(key);
      // Copy statuses into this member's own mutable map. The fixture itself
      // remains unchanged when this member edits their calendar.
      return {
        ...fixture,
        'date_statuses': Map<String, dynamic>.from(
          fixture['date_statuses'] as Map<String, dynamic>,
        ),
      };
    });
  }

  Future<LeaveData> getUserLeaveData({int? year, String? memberId}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final leaveData = LeaveData.fromJson(await _leaveDataForMember(memberId));
    final requestedYear = year ?? leaveData.selectedYear;
    if (requestedYear != leaveData.selectedYear) {
      final yearPrefix = '$requestedYear-';
      return LeaveData(
        selectedYear: requestedYear,
        leaveBalance: leaveData.leaveBalance,
        dateStatuses: Map.fromEntries(
          leaveData.dateStatuses.entries.where(
            (entry) => entry.key.startsWith(yearPrefix),
          ),
        ),
      );
    }

    return leaveData;
  }

  Future<List<LeaveCombo>> getLeaveCombos({
    int year = 2026,
    int month = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockLeaveCombos.map((json) => LeaveCombo.fromJson(json)).toList();
  }

  Future<bool> updateDateStatus(
    String dateKey,
    DateStatus status, {
    String? memberId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final memberData = await _leaveDataForMember(memberId);
    final statuses = memberData['date_statuses'] as Map<String, dynamic>;
    if (status == DateStatus.normal) {
      statuses.remove(dateKey);
    } else {
      statuses[dateKey] = status.toJson();
    }
    return true;
  }

  Future<bool> updateLeaveBalance(int newBalance, {String? memberId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final memberData = await _leaveDataForMember(memberId);
    memberData['leave_balance'] = newBalance;
    return true;
  }
}
