import '../models/trip.dart';
import '../mock/mock_trips.dart';

import 'package:flutter/foundation.dart';

class TripService {
  static final List<Trip> _createdTrips = [];
  static final ValueNotifier<int> tripListRevision = ValueNotifier(0);

  Future<List<Trip>> getTrips() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [..._createdTrips, ...mockTrips.map(Trip.fromJson)];
  }

  Future<Trip> getTrip(String tripId) async {
    final trips = await getTrips();
    return trips.firstWhere((trip) => trip.id == tripId);
  }

  Future<void> confirmTrip(Trip trip) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final confirmed = trip.copyWith(status: 'upcoming');
    final existingIndex = _createdTrips.indexWhere(
      (item) => item.id == confirmed.id,
    );
    if (existingIndex == -1) {
      _createdTrips.insert(0, confirmed);
    } else {
      _createdTrips[existingIndex] = confirmed;
    }
    tripListRevision.value++;
  }

  Future<Trip> getUpcomingTrip() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    return Trip.fromJson(mockUpcomingTrip);
  }
}
