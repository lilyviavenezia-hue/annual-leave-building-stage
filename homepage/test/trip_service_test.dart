import 'package:flutter_test/flutter_test.dart';
import 'package:homempage/models/trip.dart';
import 'package:homempage/services/trip_service.dart';

void main() {
  test('trip images flow from mock data through model and service', () async {
    final trips = await TripService().getTrips();

    expect(trips, hasLength(3));
    for (final trip in trips) {
      expect(trip.imageUrl, isNotEmpty, reason: trip.destination);
      expect(Uri.parse(trip.imageUrl).hasScheme, isTrue);

      final restored = Trip.fromJson(trip.toJson());
      expect(restored.imageUrl, trip.imageUrl);
    }
  });
}
