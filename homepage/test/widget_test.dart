// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homempage/features/chat/trip_summary_screen.dart';
import 'package:homempage/features/chat/widgets/chat_message_bubble.dart';
import 'package:homempage/features/chat/widgets/member_profile.dart';
import 'package:homempage/features/chat/widgets/summary_suggestions_tab.dart';
import 'package:homempage/features/itinerary/widgets/recommended_eats_view.dart';
import 'package:homempage/models/chat_message.dart';
import 'package:homempage/models/food_option.dart';
import 'package:homempage/models/group_member.dart';
import 'package:homempage/main.dart';

void main() {
  testWidgets('Trips tab opens the itinerary overview', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AnnualLeaveApp());

    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();

    expect(find.text('Kyoto Itinerary'), findsOneWidget);
  });

  testWidgets('Recommended eats renders the supplied food future', (
    WidgetTester tester,
  ) async {
    final foodFuture = Future.value([
      FoodOption(
        id: 'food-1',
        name: 'Kyoto Ramen',
        imageUrl: '',
        cuisineType: 'Ramen',
        priceTier: '¥¥',
        description: 'Local noodles',
        rating: 4.8,
        reviewCount: 120,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: RecommendedEatsScreen(
          destinationCity: 'Kyoto',
          foodFuture: foodFuture,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kyoto Ramen'), findsOneWidget);
  });

  testWidgets('trip summary overview shows favourites section', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TripSummaryScreen(groupId: 'group_kyoto_1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favourites'), findsOneWidget);
    expect(find.text('Attractions'), findsWidgets);
    expect(find.text('Restaurants'), findsWidgets);
    expect(find.text('Stays'), findsWidgets);
  });

  testWidgets(
    'suggestions favourites tab is available and toggles favorite state',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: SummarySuggestionsTab(
                suggestions: const [],
                destinationCity: 'Kyoto',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Attractions'));
      await tester.pumpAndSettle();
      expect(find.text('Kiyomizu-dera'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Favourite').first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Restaurants'));
      await tester.pumpAndSettle();
      expect(find.text('Gion Ramen Specialty'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Favourite').first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Stays'));
      await tester.pumpAndSettle();
      expect(find.text('Kyoto Ryokan Sano'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Favourite').first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Favourites'));
      await tester.pumpAndSettle();
      expect(find.text('Kiyomizu-dera'), findsOneWidget);
      expect(find.text('Gion Ramen Specialty'), findsOneWidget);
      expect(find.text('Kyoto Ryokan Sano'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Saved').first);
      await tester.pumpAndSettle();
      expect(find.text('Kiyomizu-dera'), findsNothing);
      expect(find.text('Gion Ramen Specialty'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Saved').first);
      await tester.pumpAndSettle();
      expect(find.text('Gion Ramen Specialty'), findsNothing);
      expect(find.text('Kyoto Ryokan Sano'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Saved').first);
      await tester.pumpAndSettle();
      expect(find.text('Kyoto Ryokan Sano'), findsNothing);
      expect(find.text('No favourite suggestions yet.'), findsOneWidget);
    },
  );

  testWidgets('chat bubble asks AI on a left swipe', (
    WidgetTester tester,
  ) async {
    var askedPrompt = '';
    final message = ChatMessage(
      id: 'swipe-test',
      senderId: 'collab_1',
      senderName: 'Sarah Chen',
      text: 'Should we visit Kyoto?',
      timestamp: DateTime(2026, 10, 4, 10, 42),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ChatMessageBubble(
              message: message,
              onAskAi: (prompt) => askedPrompt = prompt,
            ),
          ),
        ),
      ),
    );

    final bubble = find.byKey(const Key('swipe-test'));
    final bubbleWidth = tester.getSize(bubble).width;
    await tester.drag(bubble, Offset(-bubbleWidth * 0.6, 0));
    await tester.pumpAndSettle();

    expect(askedPrompt, message.text);
    expect(find.text(message.text), findsOneWidget);
  });

  testWidgets('member profile card fits a narrow chat drawer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: MemberProfileCardWidget(
              member: GroupMember(
                id: 'user_me',
                name: 'Ying (You)',
                role: 'Host',
                isMe: true,
                minBudget: 1000,
                maxBudget: 4500,
                leaveBalanceSummary: '18 Days Available',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('RM1000 – RM4500'), findsOneWidget);
  });
}
