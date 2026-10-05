import '../models/trip.dart';
import '../mock/mock_trips.dart';

import 'package:flutter/foundation.dart';

class TripService {
  static final List<Trip> _createdTrips = [];
  static final ValueNotifier<int> tripListRevision = ValueNotifier(0);

  Future<List<Trip>> getTrips() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final trips = [..._createdTrips, ...mockTrips.map(Trip.fromJson)];
    final seenTrips = <String>{};
    return trips.where((trip) {
      final identity = [
        trip.destination,
        trip.dateRange,
        trip.duration,
        trip.status.toLowerCase(),
      ].map((value) => value.trim().toLowerCase()).join('|');
      return seenTrips.add(identity);
    }).toList();
  }

  Future<Trip> getTrip(String tripId) async {
    final trips = await getTrips();
    return trips.firstWhere((trip) => trip.id == tripId);
  }

  Future<void> confirmTrip(Trip trip) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final confirmed = trip.copyWith(status: 'upcoming');
    _upsertCreatedTrip(confirmed);
    tripListRevision.value++;
  }

  Future<void> saveDraft(Trip trip) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _upsertCreatedTrip(trip.copyWith(status: 'draft'));
    tripListRevision.value++;
  }

  void _upsertCreatedTrip(Trip trip) {
    final existingIndex = _createdTrips.indexWhere(
      (item) => item.id == trip.id,
    );
    if (existingIndex == -1) {
      _createdTrips.insert(0, trip);
    } else {
      _createdTrips[existingIndex] = trip;
    }
  }

  Future<Trip> getUpcomingTrip() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    return Trip.fromJson(mockUpcomingTrip);
  }
}
