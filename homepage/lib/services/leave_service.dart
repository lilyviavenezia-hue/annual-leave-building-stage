import '../models/leave_data.dart';
import '../models/leave_combo.dart';
import '../models/leave_status.dart';
import '../mock/mock_leave.dart';

class LeaveService {
  Future<LeaveData> getUserLeaveData({int? year}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final leaveData = LeaveData.fromJson(mockLeaveData);
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
    final statuses = mockLeaveData['date_statuses'] as Map<String, dynamic>;
    if (status == DateStatus.normal) {
      statuses.remove(dateKey);
    } else {
      statuses[dateKey] = status.toJson();
    }
    return true;
  }

  Future<bool> updateLeaveBalance(int newBalance) async {
    await Future.delayed(const Duration(milliseconds: 200));
    mockLeaveData['leave_balance'] = newBalance;
    return true;
  }
}
