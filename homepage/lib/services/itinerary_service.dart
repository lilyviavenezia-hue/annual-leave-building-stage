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
    if (generated != null) return generated.overview;

    await Future.delayed(const Duration(milliseconds: 300));
    if (trip != null && itineraryId != 'ITIN_KYOTO_2026') {
      final durationDays = int.tryParse(trip.duration.split(' ').first) ?? 1;
      return ItineraryOverview(
        id: trip.id,
        title: '${trip.destination.split(',').first} Itinerary',
        destination: trip.destination,
        dateRange: trip.dateRange,
        durationDays: durationDays,
        days: List.generate(
          durationDays,
          (index) => ItineraryDayOverview(
            dayNumber: index + 1,
            dateString: 'Day ${index + 1}',
            location: trip.destination,
            stops: const [],
          ),
        ),
        categories: const ['Flights', 'Hotels', 'Attractions', 'Food'],
      );
    }
    return ItineraryOverview.fromJson(mockItineraryOverview);
  }

  Future<List<ItineraryDetailItem>> getDayDetailItems(
    String itineraryId,
    int dayNumber,
  ) async {
    final generated = _generatedItineraries[itineraryId];
    if (generated != null) {
      return generated.dayDetails[dayNumber] ?? const <ItineraryDetailItem>[];
    }

    // Simulates future backend response latency
    await Future.delayed(const Duration(milliseconds: 300));

    if (itineraryId != 'ITIN_KYOTO_2026') return [];

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
    await Future.delayed(const Duration(milliseconds: 300));
    return ItineraryOverview.fromJson(mockItineraryOverview);
  }
}
