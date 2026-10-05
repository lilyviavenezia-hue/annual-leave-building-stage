// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homempage/features/account/account_screen.dart';
import 'package:homempage/features/itinerary/widgets/recommended_eats_view.dart';
import 'package:homempage/features/chat/widgets/chat_input_field.dart';
import 'package:homempage/features/chat/chat_main_screen.dart';
import 'package:homempage/features/chat/group_chat_screen.dart';
import 'package:homempage/features/chat/widgets/summary_overview_tab.dart';
import 'package:homempage/features/trip_planning/widgets/budget_range_slider.dart';
import 'package:homempage/models/food_option.dart';
import 'package:homempage/models/group_trip_summary.dart';
import 'package:homempage/main.dart';
import 'package:homempage/services/account_service.dart';

void main() {
  testWidgets(
    'Account shows profile when signed in and sign-in when signed out',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AccountScreen())),
      );

      await tester.pumpAndSettle();
      expect(find.text('Vning'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('New here? Create an account'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField).at(0),
        'traveller@example.com',
      );
      await tester.enterText(find.byType(TextField).at(1), 'demo-password');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('traveller'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    },
  );

  testWidgets('Account settings routes and saves selected preferences', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final account = AccountService();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AccountScreen())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Comfort Family Travel'));
    await tester.pumpAndSettle();
    expect(find.text('Comfort Settings'), findsOneWidget);
    expect(find.text('Max Walking'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Accessible Transport Only'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Notifications'));
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('All notifications'), findsOneWidget);
    await tester.tap(find.text('All notifications'));
    await tester.pumpAndSettle();
    expect((await account.getNotifications()).allEnabled, isTrue);
    await tester.tap(find.text('All notifications'));
    await tester.pumpAndSettle();
    expect((await account.getNotifications()).allEnabled, isFalse);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Currency'));
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();
    expect(find.text('MYR'), findsOneWidget);
    await tester.tap(find.text('SGD').first);
    await tester.pumpAndSettle();
    expect(await account.getCurrency(), 'SGD');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Edit Profile'));
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('avatar-choice-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('avatar-choice-4')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('avatar-choice-2')));
    final selectedAvatar = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const ValueKey('avatar-choice-2')),
        matching: find.byType(Image),
      ),
    );
    expect(
      selectedAvatar.image,
      isA<AssetImage>().having(
        (asset) => asset.assetName,
        'assetName',
        'assets/avatars/ski-traveller.jpg',
      ),
    );
    expect(find.byKey(const ValueKey('avatar-choice-2')), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Vning New');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Vning New'), findsOneWidget);
    final profileFuture = account.getCurrentUser();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      (await profileFuture)?.avatarUrl,
      'assets/avatars/ski-traveller.jpg',
    );
  });

  testWidgets('Budget endpoints can be typed and stay synced with the slider', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var range = const RangeValues(500, 3000);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => BudgetRangeSlider(
              range: range,
              onChanged: (values) => setState(() => range = values),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('budget-max-input')),
      '9376',
    );
    await tester.pumpAndSettle();
    expect(range, const RangeValues(500, 9376));

    await tester.enterText(
      find.byKey(const ValueKey('budget-min-input')),
      '7500',
    );
    await tester.pumpAndSettle();
    expect(range, const RangeValues(7500, 9376));
    expect(tester.widget<RangeSlider>(find.byType(RangeSlider)).values, range);
  });

  testWidgets('Trip summary planning tiles use compact sizing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final summary = GroupTripSummary(
      groupId: 'group-test',
      title: 'Trip summary',
      dates: 'Jan 12-18',
      destination: 'Kyoto, Japan',
      budget: 'RM1000',
      progress: 0.7,
      completedItems: 5,
      totalItems: 7,
      pendingDecisions: ['Budget', 'Accommodation', 'Transport'],
      confirmedDetails: const {},
      preferenceTags: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SummaryOverviewTab(
            tripSummary: summary,
            onSelectPendingDecision: () {},
            onTagsUpdated: () {},
            onConfirmedDetailUpdated: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tile = find.ancestor(
      of: find.text('Accommodation'),
      matching: find.byType(GestureDetector),
    );
    expect(tester.getSize(tile.first).height, lessThan(70));
  });

  testWidgets('Chat composer focuses, captures, and submits typed text', (
    WidgetTester tester,
  ) async {
    final controller = TextEditingController();
    String? submittedText;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputField(
            controller: controller,
            onSend: () => submittedText = controller.text,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.testTextInput.isVisible, isTrue);
    await tester.enterText(find.byType(TextField), 'Meet at Kyoto station');
    expect(controller.text, 'Meet at Kyoto station');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    expect(submittedText, 'Meet at Kyoto station');

    controller.dispose();
  });

  testWidgets('Accepting an invitation adds a chat to the visible list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChatMainScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Accept & Join'), findsOneWidget);
    await tester.tap(find.text('Accept & Join'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Accept & Join'), findsNothing);
    expect(find.text('Tokyo Spring Blossom'), findsOneWidget);
  });

  testWidgets('Home trip card supports horizontal swiping', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.pumpAndSettle();

    expect(find.text('Upcoming Trip'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Draft Trip'), findsOneWidget);
  });

  testWidgets('Draft trip opens its own itinerary without a chevron', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_right), findsNothing);
    await tester.tap(find.text('Penang, Malaysia'));
    await tester.pumpAndSettle();

    expect(find.text('Penang Itinerary'), findsOneWidget);
    expect(find.text('Replan Trip'), findsNothing);
  });

  testWidgets('Financial page uses selected trip data and shows expenses', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kyoto, Japan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Financial summary'));
    await tester.pumpAndSettle();

    expect(find.text('Financial Summary'), findsOneWidget);
    expect(find.text('Budget progress'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Alex Ramses'), findsOneWidget);
    await tester.tap(find.byTooltip('Receipts'));
    await tester.pumpAndSettle();
    expect(find.text('Scan Receipt'), findsOneWidget);
    expect(find.text('Recent Receipts'), findsOneWidget);
    await tester.tap(find.text('Ichiran Ramen, Kyoto'));
    await tester.pumpAndSettle();
    expect(find.text('Ramen dinner'), findsOneWidget);
  });

  testWidgets('Upcoming itinerary opens the replan issue screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kyoto, Japan'));
    await tester.pumpAndSettle();
    expect(find.text('Replan Trip'), findsOneWidget);
    expect(find.byTooltip('Financial summary'), findsOneWidget);
    await tester.tap(find.text('Replan Trip'));
    await tester.pumpAndSettle();
    expect(find.text('What happened?'), findsOneWidget);
  });

  testWidgets('Home attractions render as a long vertical list', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(find.text('Recommended Attractions'), findsOneWidget);
    expect(find.text('Kiyomizu-dera'), findsOneWidget);
    expect(find.text('Yasaka Shrine'), findsOneWidget);
    expect(find.text('Add to Favourites'), findsNothing);
    expect(find.byTooltip('Add to Favourites'), findsWidgets);
    await tester.tap(find.byTooltip('Add to Favourites').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove from Favourites'), findsWidgets);
    expect(
      find.byKey(const ValueKey('attraction-details-sheet')),
      findsNothing,
    );
    await tester.tap(find.text('Kiyomizu-dera').first);
    await tester.pumpAndSettle();
    expect(find.text('Attraction details'), findsOneWidget);
    final detailsSheet = find.byKey(const ValueKey('attraction-details-sheet'));
    expect(
      find.descendant(
        of: detailsSheet,
        matching: find.text('Higashiyama-ku, Kyoto'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: detailsSheet, matching: find.text('RM 106')),
      findsOneWidget,
    );
  });

  testWidgets('Travel checklist navigates next and previous between pages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kyoto, Japan').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checklist'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('checklist-next')));
    await tester.pumpAndSettle();
    expect(find.text('Boarding pass'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ticket-previous')));
    await tester.pumpAndSettle();
    expect(find.text('Passport'), findsOneWidget);
  });

  testWidgets('Chat members sidebar shows the calendar and budget controls', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: GroupChatScreen(groupId: 'group_123')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('View Members'));
    await tester.pumpAndSettle();

    expect(find.text('Trip Members'), findsOneWidget);
    expect(find.text('AVAILABLE DATES'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.text('TRIP BUDGET RANGE (EDITABLE)'), findsOneWidget);
  });

  testWidgets('Completed trips open a memory page with photo adding', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bali, Indonesia'));
    await tester.pumpAndSettle();

    expect(find.text('Trip memories'), findsOneWidget);
    expect(find.text('Bali, Indonesia'), findsOneWidget);
    expect(find.text('Add photos'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Sunset with everyone on the beach',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bali, Indonesia'));
    await tester.pumpAndSettle();

    final noteField = tester.widget<TextField>(find.byType(TextField));
    expect(noteField.controller?.text, 'Sunset with everyone on the beach');
  });

  testWidgets('Flight, attraction, and food options can be added to the day', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kyoto, Japan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Day 1'));
    await tester.pumpAndSettle();

    for (final category in ['Flights', 'Attractions', 'Food']) {
      await tester.tap(find.text(category).first);
      await tester.pumpAndSettle();
      expect(find.text('Add to day'), findsWidgets);
      await tester.tap(find.text('Add to day').first);
      await tester.pumpAndSettle();
    }

    expect(find.text('Book flight'), findsAtLeastNWidgets(1));
    expect(find.text('Get tickets'), findsAtLeastNWidgets(1));
    expect(find.text('Reserve table'), findsAtLeastNWidgets(1));
  });

  testWidgets('Trips tab opens Kyoto overview and its Day 1 timeline', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());

    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsWidgets);
    expect(find.text('Kyoto, Japan'), findsOneWidget);

    await tester.tap(find.text('Kyoto, Japan'));
    await tester.pumpAndSettle();

    expect(find.text('Kyoto Itinerary'), findsOneWidget);

    await tester.tap(find.text('Day 1'));
    await tester.pumpAndSettle();

    expect(find.text('Flight KUL → KIX'), findsOneWidget);
    expect(find.text('Hotels'), findsOneWidget);
    expect(find.text('Close'), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('itinerary-panel-handle')),
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Hotels'));
    await tester.pumpAndSettle();
    expect(find.text('Kyoto Ryokan Sano'), findsOneWidget);

    final hotelPosition = tester.getCenter(find.text('Kyoto Ryokan Sano'));
    final panelTop = tester
        .getTopLeft(find.byKey(const ValueKey('itinerary-panel-handle')))
        .dy;
    final timelineRect = tester.getRect(
      find.byKey(const ValueKey('itinerary-timeline-drop-target')),
    );
    final timelinePosition = Offset(timelineRect.center.dx, panelTop - 8);
    await tester.timedDragFrom(
      hotelPosition,
      timelinePosition - hotelPosition,
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Kyoto Ryokan Sano scheduled for'),
      findsOneWidget,
    );
    expect(find.text('Book stay'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Checklist'));
    await tester.pumpAndSettle();
    expect(find.text('Travel Checklist'), findsOneWidget);
    expect(find.text('4 of 9 completed'), findsOneWidget);

    await tester.tap(find.text('Flight ticket'));
    await tester.pumpAndSettle();
    expect(find.text('Ticket saved'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Financial summary'));
    await tester.pumpAndSettle();
    expect(find.text('Financial Summary'), findsOneWidget);
    expect(find.textContaining('RM 2480'), findsOneWidget);
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

  testWidgets('Trip creation reports an unavailable generation backend', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AnnualLeaveApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create a new trip'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Generate my itinerary'));
    await tester.tap(find.text('Generate my itinerary'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Unable to generate itinerary'), findsOneWidget);
    expect(find.text('Generate my itinerary'), findsOneWidget);
  });
}
