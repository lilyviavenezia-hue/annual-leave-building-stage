import '../core/api/api_client.dart';
import '../mock/mock_preferences.dart';
import '../models/itinerary.dart';
import '../models/travel_preference.dart';
import '../models/trip.dart';
import '../models/trip_customization.dart';

class PreferenceService {
  final ApiClient _apiClient;

  PreferenceService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // --- Travel Preferences Methods ---

  Future<TravelPreference> getPreferences() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return TravelPreference.fromJson(mockTravelPreference);
  }

  Future<bool> savePreferences(TravelPreference preference) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // FUTURE PYTHON BACKEND CALL:
    // await apiClient!.post('/api/preferences', preference.toJson());
    return true;
  }

  Future<GeneratedItinerary> generateItinerary({
    required Trip trip,
    required TravelPreference preference,
  }) async {
    final response = await _apiClient.post('/api/itinerary/generate', {
      'trip': trip.toJson(),
      'preferences': preference.toJson(),
    });
    return GeneratedItinerary.fromJson(response);
  }

  // --- Swipe / Trip Customization Methods ---

  Future<List<PreferenceCardItem>> getSwipeCards() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockSwipeCards.map((e) => PreferenceCardItem.fromJson(e)).toList();
  }

  Future<bool> saveTripCustomization({
    required List<PreferenceCardItem> top3Choices,
    required List<String> interestedIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // FUTURE PYTHON BACKEND CALL:
    // await apiClient!.post('/api/trips/customize', {
    //   'top_3': top3Choices.map((e) => e.id).toList(),
    //   'interested_ids': interestedIds,
    // });
    return true;
  }
}