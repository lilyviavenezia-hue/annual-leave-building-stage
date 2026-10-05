import 'package:flutter_test/flutter_test.dart';

import 'package:homempage/models/budget.dart';
import 'package:homempage/services/budget_service.dart';
import 'package:homempage/services/expense_service.dart';

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
}
