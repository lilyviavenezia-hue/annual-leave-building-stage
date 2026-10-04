import '../mock/mock_replan_alternatives.dart';
import '../models/replan_alternative.dart';

class ReplanService {
  List<ReplanAlternative> getNearbyAlternatives(String destination) {
    final city = destination.split(',').first.trim().toLowerCase();
    if (city != 'kyoto') {
      return const [];
    }
    return mockKyotoReplanAlternatives
        .map(ReplanAlternative.fromJson)
        .toList(growable: false);
  }
}
