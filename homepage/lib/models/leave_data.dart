import 'package:homempage/models/leave_status.dart';

class LeaveData {
  final int selectedYear;
  final int leaveBalance;
  final Map<String, DateStatus> dateStatuses;

  LeaveData({
    required this.selectedYear,
    required this.leaveBalance,
    required this.dateStatuses,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawStatuses = json['date_statuses'] ?? {};
    final Map<String, DateStatus> parsedStatuses = {};

    rawStatuses.forEach((key, value) {
      parsedStatuses[key] = DateStatusX.fromString(value.toString());
    });

    return LeaveData(
      selectedYear: json['selected_year'] ?? 2026,
      leaveBalance: json['leave_balance'] ?? 0,
      dateStatuses: parsedStatuses,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, String> jsonStatuses = {};
    dateStatuses.forEach((key, value) {
      jsonStatuses[key] = value.toJson();
    });

    return {
      'selected_year': selectedYear,
      'leave_balance': leaveBalance,
      'date_statuses': jsonStatuses,
    };
  }
}