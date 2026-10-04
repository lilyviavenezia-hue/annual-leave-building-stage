import '../core/api/api_client.dart';
import '../mock/mock_preferences.dart';
import '../models/travel_preference.dart';
import '../models/trip_customization.dart';

class PreferenceService {
  final ApiClient? apiClient;

  PreferenceService({this.apiClient});

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

  Future<bool> generateItinerary(TravelPreference preference) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // FUTURE PYTHON BACKEND CALL:
    // await apiClient!.post('/api/itinerary/generate', preference.toJson());
    return true;
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