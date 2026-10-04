import 'package:flutter_test/flutter_test.dart';

import 'package:homempage/models/budget.dart';
import 'package:homempage/services/budget_service.dart';
import 'package:homempage/services/trip_service.dart';

void main() {
  test('budget summary uses mock flight and hotel values and marks flight as booked', () async {
    final summary = await BudgetService().getCalculatedBudget('group_123');

    expect(summary.groupId, 'group_123');
    expect(summary.totalAmount, greaterThan(0.0));
    expect(summary.items.first.category, 'Flight');
    expect(summary.items.first.status, BudgetStatus.booked);
    expect(summary.items[1].category, 'Accommodation');
  });

  test(
    'trip estimate derives cost from planned duration and travellers',
    () async {
      final trips = await TripService().getTrips();
      final kyoto = trips.firstWhere((trip) => trip.id == 'ITIN_KYOTO_2026');
      final estimate = await BudgetService().getTripEstimate(kyoto);

      expect(estimate.durationDays, 6);
      expect(estimate.travellerCount, 4);
      expect(estimate.plannedBudget, 2000);
      expect(estimate.estimatedTotal, 2480);
      expect(estimate.costPerPerson, 620);
      expect(
        estimate.categories.fold<double>(
          0,
          (total, category) => total + category.amount,
        ),
        estimate.estimatedTotal,
      );
    },
  );
}
