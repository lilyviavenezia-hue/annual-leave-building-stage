import '../mock/mock_itinerary.dart';
import '../models/itinerary.dart';
import '../models/trip.dart';

class ItineraryService {
  static final Map<String, GeneratedItinerary> _generatedItineraries = {};

  static void saveGeneratedItinerary(GeneratedItinerary itinerary) {
    _generatedItineraries[itinerary.overview.id] = itinerary;
  }

  Future<ItineraryOverview> getItineraryOverview(
    String itineraryId, {
    Trip? trip,
  }) async {
    final generated = _generatedItineraries[itineraryId];

    if (generated != null) {
      return generated.overview;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return ItineraryOverview.fromJson(mockItineraryOverview);
  }

  Future<List<ItineraryDetailItem>> getDayDetailItems(
    String itineraryId,
    int dayNumber,
  ) async {
    final generated = _generatedItineraries[itineraryId];

    if (generated != null) {
      return generated.dayDetails[dayNumber] ??
          const <ItineraryDetailItem>[];
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final dayDetailsMap =
        mockItineraryOverview['day_details'] as Map<String, dynamic>?;

    if (dayDetailsMap != null &&
        dayDetailsMap.containsKey(dayNumber.toString())) {
      final list = dayDetailsMap[dayNumber.toString()] as List<dynamic>;

      return list
          .map(
            (item) =>
                ItineraryDetailItem.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return [];
  }

  Future<ItineraryOverview> getItinerary(String itineraryId) async {
    final generated = _generatedItineraries[itineraryId];

    if (generated != null) {
      return generated.overview;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return ItineraryOverview.fromJson(mockItineraryOverview);
  }
}
