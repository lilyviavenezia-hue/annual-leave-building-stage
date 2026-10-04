import '../mock/mock_flights.dart';
import '../models/flight.dart';

class FlightService {
  Future<List<FlightOption>> searchFlights(String originCode, String destinationCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mockFlightSearchResults['origin_code'] != originCode ||
        mockFlightSearchResults['destination_code'] != destinationCode) {
      return [];
    }

    final flights = mockFlightSearchResults['flights'] as List<dynamic>;
    return flights
        .map((item) => FlightOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FlightDateChip>> getFlightDateChips(String originCode, String destinationCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mockFlightSearchResults['origin_code'] != originCode ||
        mockFlightSearchResults['destination_code'] != destinationCode) {
      return [];
    }

    final dateChips = mockFlightSearchResults['date_chips'] as List<dynamic>;
    return dateChips
        .map((item) => FlightDateChip.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FlightOption>> getFlights() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final flights = mockFlightSearchResults['flights'] as List<dynamic>? ?? [];
    return flights
        .map((item) => FlightOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}