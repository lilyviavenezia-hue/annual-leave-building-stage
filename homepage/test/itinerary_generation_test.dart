import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:homempage/core/api/api_client.dart';
import 'package:homempage/features/trip_planning/travel_preferences.dart';
import 'package:homempage/models/itinerary.dart';
import 'package:homempage/models/travel_preference.dart';
import 'package:homempage/models/trip.dart';
import 'package:homempage/services/preference_service.dart';

void main() {
  test(
    'generation sends trip and preferences and parses the full plan',
    () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(_generatedPlan),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = PreferenceService(
        apiClient: ApiClient(
          baseUrl: 'http://localhost:8000',
          httpClient: client,
        ),
      );
      final trip = _trip();
      final preferences = TravelPreference(
        transcript: 'A relaxed cultural trip with local coffee shops.',
        pace: 'Relaxed',
        accessibility: 'Wheelchair-friendly',
        restroomPriority: 'High',
        startTime: '09:00 AM',
        endTime: '07:00 PM',
      );

      final result = await service.generateItinerary(
        trip: trip,
        preference: preferences,
      );
      final requestBody =
          jsonDecode(capturedRequest.body) as Map<String, dynamic>;

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/api/itinerary/generate');
      expect(requestBody['trip'], trip.toJson());
      expect(requestBody['preferences'], preferences.toJson());
      expect(result.overview.title, 'Kyoto Itinerary');
      expect(result.overview.days.single.stops.single.name, 'Nishiki Market');
      expect(result.dayDetails[1]!.single.title, 'Explore Nishiki Market');
      expect(result.estimatedBudget, 2480);
      expect(result.budgetBreakdown!['Transport'], 640);

      client.close();
    },
  );

  test('generation rejects incomplete daily plans', () async {
    final incompletePlan = {
      ..._generatedPlan,
      'day_details': <String, dynamic>{},
    };
    final service = PreferenceService(
      apiClient: ApiClient(
        httpClient: MockClient(
          (_) async => http.Response(jsonEncode(incompletePlan), 200),
        ),
      ),
    );

    await expectLater(
      service.generateItinerary(trip: _trip(), preference: _preference()),
      throwsA(isA<FormatException>()),
    );
  });

  test('generation reports non-success backend status codes', () async {
    final service = PreferenceService(
      apiClient: ApiClient(
        httpClient: MockClient((_) async => http.Response('unavailable', 503)),
      ),
    );

    await expectLater(
      service.generateItinerary(trip: _trip(), preference: _preference()),
      throwsA(isA<ApiException>()),
    );
  });

  testWidgets(
    'Generate submits edited preferences, displays the plan, and opens budget',
    (tester) async {
      final service = _StubPreferenceService();
      await tester.pumpWidget(
        MaterialApp(
          home: TravelPreferencesScreen(
            tripDraft: _trip(),
            preferenceService: service,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'Quiet cafes and cultural walks.',
      );
      await tester.tap(find.text('Generate my itinerary'));
      await tester.pumpAndSettle();

      expect(
        service.receivedPreference?.transcript,
        'Quiet cafes and cultural walks.',
      );
      expect(find.text('Kyoto Itinerary'), findsOneWidget);
      expect(find.text('Nishiki Market'), findsOneWidget);

      await tester.tap(find.text('Day 1'));
      await tester.pumpAndSettle();
      expect(find.text('Explore Nishiki Market'), findsOneWidget);

      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proceed to budget'));
      await tester.pumpAndSettle();
      expect(find.text('Budget summary'), findsOneWidget);
      expect(find.text('Flights'), findsOneWidget);
      expect(find.text('Accommodation'), findsOneWidget);
      expect(find.text('Not yet booked'), findsNWidgets(2));
      await tester.drag(find.byType(ListView).last, const Offset(0, -700));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Your trip is confirmed!'), findsOneWidget);
    },
  );
}

Trip _trip() => Trip(
  id: 'TRIP_API',
  destination: 'Kyoto, Japan',
  dateRange: '12 - 12 October 2026',
  duration: '1 days',
  budget: 'RM 3,000 budget',
  imageUrl: '',
  status: 'draft',
  travellerCount: 2,
  plannedBudget: 3000,
);

TravelPreference _preference() => TravelPreference(
  transcript: 'A relaxed cultural trip.',
  pace: 'Relaxed',
  accessibility: 'Standard',
  restroomPriority: 'Medium',
  startTime: '08:00 AM',
  endTime: '09:00 PM',
);

const _generatedPlan = {
  'itinerary': {
    'id': 'TRIP_API',
    'title': 'Kyoto Itinerary',
    'destination': 'Kyoto, Japan',
    'date_range': '12 October 2026',
    'duration_days': 1,
    'categories': ['Flights', 'Hotels', 'Attractions', 'Food'],
    'origin_code': 'KUL',
    'destination_code': 'KIX',
    'origin_city': 'Kuala Lumpur',
    'destination_city': 'Kyoto',
    'days': [
      {
        'day_number': 1,
        'date_string': 'Mon, 12 Oct',
        'location': 'Kyoto, Japan',
        'stops': [
          {'id': 'stop-1', 'name': 'Nishiki Market'},
        ],
      },
    ],
  },
  'day_details': {
    '1': [
      {
        'id': 'activity-1',
        'time_start': '10:00 AM',
        'time_end': '12:00 PM',
        'title': 'Explore Nishiki Market',
        'subtitle': 'Sample local food and browse specialty shops.',
        'duration': '2 hrs',
        'mode': 'Walk',
        'type': 'attraction',
        'booking_url': '',
      },
    ],
  },
  'estimated_budget': 2480,
  'budget_breakdown': {
    'Transport': 640,
    'Accommodation': 560,
    'Food': 420,
    'Activities': 360,
    'Other expenses': 500,
  },
};

class _StubPreferenceService extends PreferenceService {
  TravelPreference? receivedPreference;

  @override
  Future<TravelPreference> getPreferences() async => _preference();

  @override
  Future<GeneratedItinerary> generateItinerary({
    required Trip trip,
    required TravelPreference preference,
  }) async {
    receivedPreference = preference;
    return GeneratedItinerary.fromJson(_generatedPlan);
  }
}
