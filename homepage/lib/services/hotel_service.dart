import '../mock/mock_hotels.dart';
import '../models/hotel.dart';

class HotelService {
  Future<List<HotelOption>> searchHotels(String destination) async {
    // Simulates API fetch latency
    await Future.delayed(const Duration(milliseconds: 300));

    final list = mockHotelSearchResults['hotels'] as List<dynamic>?;
    if (list != null) {
      return list
          .map((item) => HotelOption.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<HotelOption>> getHotels() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = mockHotelSearchResults['hotels'] as List<dynamic>? ?? [];
    return list
        .map((item) => HotelOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> setHotelFavourite(String id, bool isFavourite) {
    final hotels = mockHotelSearchResults['hotels'] as List<dynamic>? ?? const [];
    final hotel = hotels.where((item) => (item as Map)['id'] == id);
    if (hotel.isEmpty) return Future.value(false);

    (hotel.first as Map<String, dynamic>)['is_favourite'] = isFavourite;
    return Future.value(true);
  }
}