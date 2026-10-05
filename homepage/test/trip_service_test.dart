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

  test('identical trips with separate ids are listed only once', () async {
    final service = TripService();
    final firstCopy = Trip(
      id: 'DUPLICATE_TEST_FIRST',
      destination: 'Sample duplicate destination',
      dateRange: '1 - 3 January 2030',
      duration: '2 days',
      budget: 'RM 1,000 budget',
      imageUrl: '',
      status: 'draft',
    );
    final secondCopy = firstCopy.copyWith(id: 'DUPLICATE_TEST_SECOND');
    await service.saveDraft(firstCopy);
    await service.saveDraft(secondCopy);

    final matches = (await service.getTrips())
        .where((trip) => trip.destination == firstCopy.destination)
        .toList();

    expect(matches, hasLength(1));
    expect(matches.single.id, secondCopy.id);
  });
}
