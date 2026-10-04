import '../models/leave_data.dart';
import '../models/leave_combo.dart';
import '../mock/mock_leave.dart';

class LeaveService {
  Future<LeaveData> getUserLeaveData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return LeaveData.fromJson(mockLeaveData);
  }

  Future<List<LeaveCombo>> getLeaveCombos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockLeaveCombos
        .map((json) => LeaveCombo.fromJson(json))
        .toList();
  }

  Future<bool> updateLeaveBalance(int newBalance) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}