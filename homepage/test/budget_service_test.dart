import 'package:flutter_test/flutter_test.dart';

import 'package:homempage/models/budget.dart';
import 'package:homempage/services/budget_service.dart';
import 'package:homempage/services/expense_service.dart';
import 'package:homempage/services/group_summary_service.dart';

void main() {
  test('budget summary uses mock flight and hotel values and marks flight as booked', () async {
    final summary = await BudgetService().getCalculatedBudget('group_123');

    expect(summary.groupId, 'group_123');
    expect(summary.totalAmount, greaterThan(0.0));
    expect(summary.items.first.category, 'Flight');
    expect(summary.items.first.status, BudgetStatus.booked);
    expect(summary.items[1].category, 'Accommodation');
  });

  test('expense service returns recent receipts from mock data', () async {
    final receipts = await ExpenseService().getRecentReceipts();

    expect(receipts, isNotEmpty);
    expect(receipts.first.merchantName, isNotEmpty);
    expect(receipts.first.items, isNotEmpty);
  });

  test('group summary service updates member budget, date range and preferences', () async {
    final service = GroupSummaryService();
    const groupId = 'group_kyoto_1';
    const userId = 'user_me';

    final before = await service.getGroupMembers(groupId);
    final user = before.firstWhere((member) => member.id == userId);

    expect(await service.updateMemberBudget(
      memberId: userId,
      minBudget: 2500,
      maxBudget: 6200,
    ), isTrue);
    expect(await service.updateMemberDateRange(
      memberId: userId,
      dateRange: 'Oct 20 - Oct 28, 2026',
    ), isTrue);
    expect(await service.updateMemberPreferences(
      memberId: userId,
      preferences: ['Food', 'Culture', 'Night market'],
    ), isTrue);

    final updated = await service.getGroupMembers(groupId);
    final refreshedUser = updated.firstWhere((member) => member.id == userId);

    expect(refreshedUser.minBudget, 2500);
    expect(refreshedUser.maxBudget, 6200);
    expect(refreshedUser.dateRange, 'Oct 20 - Oct 28, 2026');
    expect(refreshedUser.preferences, ['Food', 'Culture', 'Night market']);
  });
}
