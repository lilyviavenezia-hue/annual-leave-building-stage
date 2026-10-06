import 'package:go_router/go_router.dart';
import 'main_navigation.dart';
import 'placeholder_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/itinerary/itinerary_overview_screen.dart';
import '../../features/chat/chat_main_screen.dart';
import '../../features/chat/group_chat_screen.dart';
import '../../features/account/account_screen.dart';
import '../../features/trips/financial_summary_screen.dart';
import '../../features/trips/travel_checklist_screen.dart';
import '../../features/trips/trip_memories_screen.dart';
import '../../models/trip.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationWrapper(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'details',
                  builder: (context, state) =>
                      const PlaceholderScreen(title: 'Home Details'),
                ),
                // Itinerary route under Home using state.extra
                GoRoute(
                  path: 'itinerary',
                  builder: (context, state) {
                    final itineraryId = state.extra as String? ?? '';
                    return ItineraryOverviewScreen(itineraryId: itineraryId);
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 1: Trips / Itinerary Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trips',
              builder: (context, state) => const ItineraryOverviewScreen(
                itineraryId: 'ITIN_KYOTO_2026',
              ),
              routes: [
                GoRoute(
                  path: ':tripId',
                  builder: (context, state) {
                    final tripId = state.pathParameters['tripId']!;
                    final trip = state.extra is Trip ? state.extra as Trip : null;
                    return ItineraryOverviewScreen(
                      itineraryId: tripId,
                      initialTrip: trip,
                    );
                  },
                ),
                GoRoute(
                  path: ':tripId/checklist',
                  builder: (context, state) {
                    final tripId = state.pathParameters['tripId']!;
                    return TravelChecklistScreen();
                  },
                ),
                GoRoute(
                  path: ':tripId/financial-summary',
                  builder: (context, state) {
                    final tripId = state.pathParameters['tripId']!;
                    final trip = state.extra is Trip ? state.extra as Trip : null;
                    return FinancialSummaryScreen(
                      tripId: tripId,
                      trip: trip,
                    );
                  },
                ),
                GoRoute(
                  path: ':tripId/memories',
                  builder: (context, state) {
                    final tripId = state.pathParameters['tripId']!;
                    final trip = state.extra is Trip ? state.extra as Trip : null;
                    return TripMemoriesScreen(
                      tripId: tripId,
                      initialTrip: trip,
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 2: Chat Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatMainScreen(),
              routes: [
                GoRoute(
                  path: ':groupId',
                  builder: (context, state) {
                    final groupId = state.pathParameters['groupId']!;
                    return GroupChatScreen(groupId: groupId);
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 3: Account Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);