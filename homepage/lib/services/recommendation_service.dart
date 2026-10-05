import '../models/recommendation.dart';
import '../models/attraction.dart'; 
import '../mock/mock_recommendations.dart';

class RecommendationService {
  Future<List<Recommendation>> getTopPicks() async {
    // Simulate network delay for API readiness
    await Future.delayed(const Duration(milliseconds: 300));
    return mockTopPicks
        .map((json) => Recommendation.fromJson(json))
        .toList();
  }

  Future<List<Attraction>> getRecommendedAttractions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockRecommendedAttractions
        .map((json) => Attraction.fromJson(json))
        .toList();
  }

  Future<bool> setAttractionFavourite(String id, bool isFavourite) {
    final attraction = mockRecommendedAttractions.where(
      (item) => item['id'] == id,
    );
    if (attraction.isEmpty) return Future.value(false);

    attraction.first['is_favourite'] = isFavourite;
    return Future.value(true);
  }
}