import '../mock/mock_itinerary.dart';
import '../models/itinerary.dart';

class ItineraryService {
  Future<ItineraryOverview> getItineraryOverview(String itineraryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ItineraryOverview.fromJson(mockItineraryOverview);
  }

  Future<List<ItineraryDetailItem>> getDayDetailItems(String itineraryId, int dayNumber) async {
    // Simulates future backend response latency
    await Future.delayed(const Duration(milliseconds: 300));

    final dayDetailsMap = mockItineraryOverview['day_details'] as Map<String, dynamic>?;
    if (dayDetailsMap != null && dayDetailsMap.containsKey(dayNumber.toString())) {
      final list = dayDetailsMap[dayNumber.toString()] as List<dynamic>;
      return list.map((item) => ItineraryDetailItem.fromJson(item as Map<String, dynamic>)).toList();
    }

    return [];
  }

  Future<ItineraryOverview> getItinerary(String itineraryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ItineraryOverview.fromJson(mockItineraryOverview);
  }
}