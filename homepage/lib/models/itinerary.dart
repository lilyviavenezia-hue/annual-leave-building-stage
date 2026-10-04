import 'package:flutter/material.dart';

import 'attraction.dart';
import 'flight.dart';
import 'food_option.dart';
import 'hotel.dart';

class ItineraryScheduleOption {
  const ItineraryScheduleOption._();

  static ItineraryDetailItem flight(FlightOption flight) {
    return ItineraryDetailItem(
      id: 'flight-${flight.id}',
      timeStart: '9:00 AM',
      timeEnd: '10:30 AM',
      title: '${flight.airlineName} · ${flight.flightType}',
      subtitle:
          '${flight.departureTime} - ${flight.arrivalTime} · ${flight.duration} · ${flight.priceFormatted}',
      duration: flight.duration,
      mode: 'Flight',
      type: 'flight',
      bookingUrl: flight.bookingUrl,
    );
  }

  static ItineraryDetailItem hotel(HotelOption hotel) {
    return ItineraryDetailItem(
      id: 'hotel-${hotel.id}',
      timeStart: '2:00 PM',
      timeEnd: '3:00 PM',
      title: hotel.name,
      subtitle: '${hotel.location} · ${hotel.pricePerNightFormatted}',
      duration: '1 hr',
      mode: 'Stay',
      type: 'hotel',
      bookingUrl: hotel.bookingUrl,
    );
  }

  static ItineraryDetailItem attraction(Attraction attraction) {
    return ItineraryDetailItem(
      id: 'attraction-${attraction.id}',
      timeStart: '10:00 AM',
      timeEnd: '11:30 AM',
      title: attraction.title,
      subtitle: attraction.location,
      duration: '1 hr 30 mins',
      mode: 'Visit',
      type: 'attraction',
    );
  }

  static ItineraryDetailItem food(FoodOption food) {
    return ItineraryDetailItem(
      id: 'food-${food.id}',
      timeStart: '12:00 PM',
      timeEnd: '1:00 PM',
      title: food.name,
      subtitle: '${food.cuisineType} · ${food.priceTier} · ${food.rating}★',
      duration: '1 hr',
      mode: 'Meal',
      type: 'food',
    );
  }
}

class ItineraryOverview {
  final String id;
  final String title;
  final String destination;
  final String dateRange;
  final int durationDays;
  final List<ItineraryDayOverview> days;
  final List<String>? categories;
  final String? originCode;
  final String? destinationCode;
  final String? originCity;
  final String? destinationCity;

  const ItineraryOverview({
    required this.id,
    required this.title,
    required this.destination,
    required this.dateRange,
    required this.durationDays,
    required this.days,
    this.categories,
    this.originCode,
    this.destinationCode,
    this.originCity,
    this.destinationCity,
  });

  factory ItineraryOverview.fromJson(Map<String, dynamic> json) {
    return ItineraryOverview(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      dateRange: json['date_range'] as String? ?? '',
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
      days: (json['days'] as List<dynamic>? ?? [])
          .map(
            (day) => ItineraryDayOverview.fromJson(day as Map<String, dynamic>),
          )
          .toList(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((category) => category as String)
          .toList(),
      originCode: json['origin_code'] as String?,
      destinationCode: json['destination_code'] as String?,
      originCity: json['origin_city'] as String?,
      destinationCity: json['destination_city'] as String?,
    );
  }
}

class ItineraryDayOverview {
  final int dayNumber;
  final String dateString;
  final String location;
  final List<ItineraryStop> stops;

  const ItineraryDayOverview({
    required this.dayNumber,
    required this.dateString,
    required this.location,
    required this.stops,
  });

  factory ItineraryDayOverview.fromJson(Map<String, dynamic> json) {
    return ItineraryDayOverview(
      dayNumber: (json['day_number'] as num?)?.toInt() ?? 0,
      dateString: json['date_string'] as String? ?? '',
      location: json['location'] as String? ?? '',
      stops: (json['stops'] as List<dynamic>? ?? [])
          .map((stop) => ItineraryStop.fromJson(stop as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ItineraryStop {
  final String id;
  final String name;

  const ItineraryStop({required this.id, required this.name});

  factory ItineraryStop.fromJson(Map<String, dynamic> json) {
    return ItineraryStop(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class ItineraryDetailItem {
  final String id;
  final String timeStart;
  final String timeEnd;
  final String title;
  final String subtitle;
  final String duration;
  final String mode;
  final String type;
  final String bookingUrl;

  ItineraryDetailItem({
    required this.id,
    required this.timeStart,
    required this.timeEnd,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.mode,
    required this.type,
    this.bookingUrl = '',
  });

  factory ItineraryDetailItem.fromJson(Map<String, dynamic> json) {
    return ItineraryDetailItem(
      id: json['id'] ?? '',
      timeStart: json['time_start'] ?? '',
      timeEnd: json['time_end'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      duration: json['duration'] ?? '',
      mode: json['mode'] ?? '',
      type: json['type'] ?? '',
      bookingUrl: json['booking_url'] ?? '',
    );
  }

  ItineraryDetailItem copyWith({String? timeStart, String? timeEnd}) {
    return ItineraryDetailItem(
      id: id,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      title: title,
      subtitle: subtitle,
      duration: duration,
      mode: mode,
      type: type,
      bookingUrl: bookingUrl,
    );
  }

  // Maps activity type to tag color matching UI specs
  Color get timeTagBgColor {
    switch (type) {
      case 'flight':
        return const Color(0xFFF3EED9);
      case 'hotel':
        return const Color(0xFFF2E2E2);
      case 'transit':
        return const Color(0xFFE2ECF2);
      case 'attraction':
      default:
        return const Color(0xFFE2F0E8);
    }
  }
}
