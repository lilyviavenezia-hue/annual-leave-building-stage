import '../models/planning_trip.dart';
import '../mock/mock_trips.dart';

class PlanningService {
  Future<PlanningTrip> getCurrentPlanningTrip() async {
    // Simulate network latency for API preparation
    await Future.delayed(const Duration(milliseconds: 300));
    return PlanningTrip.fromJson(mockCurrentPlanningTrip);
  }
}