import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/planning_trip.dart';

class PlanningTripCard extends StatelessWidget {
  final String flagEmoji;
  final String destination;
  final String dateRange;
  final String duration;
  final int daysToGo;
  final double progress; // Value between 0.0 and 1.0

  const PlanningTripCard({
    super.key,
    required this.flagEmoji,
    required this.destination,
    required this.dateRange,
    required this.duration,
    required this.daysToGo,
    required this.progress,
  });

  /// Factory constructor to create card directly from a PlanningTrip model
  factory PlanningTripCard.fromModel({
    Key? key,
    required PlanningTrip trip,
  }) {
    return PlanningTripCard(
      key: key,
      flagEmoji: trip.flagEmoji,
      destination: trip.destination,
      dateRange: trip.dateRange,
      duration: trip.duration,
      daysToGo: trip.daysToGo,
      progress: trip.progress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (progress.clamp(0.0, 1.0) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Destination Title with Flag
          Row(
            children: [
              Text(
                flagEmoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Text(
                destination,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          // 2. Date & Duration
          Text(
            '$dateRange  •  $duration',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),

          // 3. Days to go (Smaller muted subtext)
          Text(
            '$daysToGo days to go',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),

          // 4. Progress Bar Section
          Row(
            children: [
              const Text(
                'Progress:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.black.withValues(alpha: 0.06),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}