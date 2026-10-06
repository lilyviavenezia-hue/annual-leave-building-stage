import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/planning_trip.dart';
import '../../services/planning_service.dart';
import 'widgets/widgets.dart';
import 'leave_optimizer/leave_optimizer_screen.dart';
import '../trip_planning/create_trip_screen.dart';
import '../trip_planning/trip_planning_screen.dart'; // Adjust path as per project structure

/// Main Home Screen Implementation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlanningService _planningService = PlanningService();
  late Future<PlanningTrip> _planningTripFuture;

  @override
  void initState() {
    super.initState();
    _planningTripFuture = _planningService.getCurrentPlanningTrip();
  }

  // Navigation to Create Trip Screen
  void _navigateToCreateTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTripScreen(),
      ),
    );
  }

  // Open Default Preferences Bottom Sheet Modal
  void _openPlanningModal() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DefaultPreferencesOverlay(transcript: ''),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully!')),
      );
    }
  }

  // Open Leave Optimizer Bottom Sheet Modal
  void _openLeaveOptimizerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LeaveOptimizerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Summary Card
          const UpcomingTripCard(),
          const SizedBox(height: 20),

          // 2. Primary Action Button with Leave Optimizer Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _navigateToCreateTrip,
                  icon: const Icon(Icons.add, color: AppTheme.backgroundWhite, size: 22),
                  label: const Text(
                    'Create a new trip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.backgroundWhite,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -12,
                right: -12,
                child: Tooltip(
                  message: 'Leave Optimizer',
                  child: Material(
                    color: AppTheme.primaryBlue,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: InkWell(
                      onTap: _openLeaveOptimizerModal,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.backgroundWhite,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 3. Current Planning Trip Section
          const Text(
            'Current Planning Trip',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),

          FutureBuilder<PlanningTrip>(
            future: _planningTripFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'No active planning trip found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final trip = snapshot.data!;

              return GestureDetector(
                onTap: _openPlanningModal,
                child: PlanningTripCard(
                  flagEmoji: trip.flagEmoji,
                  destination: trip.destination,
                  dateRange: trip.dateRange,
                  duration: trip.duration,
                  daysToGo: trip.daysToGo,
                  progress: trip.progress,
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // 4. Top Picks For You Section
          const Text(
            'Top Picks for You',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),
          const TopPicksSection(),
          const SizedBox(height: 28),

          // 5. Recommended Attractions Section
          const Text(
            'Recommended Attractions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),
          const RecommendedAttractionsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}