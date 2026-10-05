import '../models/leave_data.dart';
import '../models/leave_combo.dart';
import '../models/leave_status.dart';
import '../mock/mock_leave.dart';
import 'account_service.dart';

class LeaveService {
  static final Map<String, Map<String, dynamic>> _leaveDataByUser = {};

  Future<Map<String, dynamic>> _userLeaveData() async {
    final profile = await AccountService().getCurrentUser();
    final userId = profile?.userId.trim();
    final key = userId == null || userId.isEmpty ? 'signed_out' : userId;
    return _leaveDataByUser.putIfAbsent(key, () {
      // Keep the existing demo calendar for the initially signed-in demo user.
      // Other accounts get their own clean leave calendar and balance.
      if (key == '5574 5687 1125 5115') {
        return {
          ...mockLeaveData,
          'date_statuses': Map<String, dynamic>.from(
            mockLeaveData['date_statuses'] as Map<String, dynamic>,
          ),
        };
      }
      return {
        'selected_year': DateTime.now().year,
        'leave_balance': 18,
        'date_statuses': <String, dynamic>{},
      };
    });
  }

  Future<LeaveData> getUserLeaveData({int? year}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final leaveData = LeaveData.fromJson(await _userLeaveData());
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

  Future<bool> updateDateStatus(String dateKey, DateStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userData = await _userLeaveData();
    final statuses = userData['date_statuses'] as Map<String, dynamic>;
    if (status == DateStatus.normal) {
      statuses.remove(dateKey);
    } else {
      statuses[dateKey] = status.toJson();
    }
    return true;
  }

  Future<bool> updateLeaveBalance(int newBalance) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userData = await _userLeaveData();
    userData['leave_balance'] = newBalance;
    return true;
  }
}
