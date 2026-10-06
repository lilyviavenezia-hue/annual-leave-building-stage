import '../mock/mock_food.dart';
import '../models/food_option.dart';

class FoodService {
  Future<List<FoodOption>> getRecommendedEats(String destination) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final list = mockFoodSearchResults['eats'] as List<dynamic>?;
    if (list != null) {
      return list
          .map((item) => FoodOption.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  Future<bool> setFoodFavourite(String id, bool isFavourite) {
    final eats = mockFoodSearchResults['eats'] as List<dynamic>? ?? const [];
    final food = eats.where((item) => (item as Map)['id'] == id);
    if (food.isEmpty) return Future.value(false);

    (food.first as Map<String, dynamic>)['is_favourite'] = isFavourite;
    return Future.value(true);
  }
}