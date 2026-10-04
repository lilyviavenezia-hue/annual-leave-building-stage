import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/trip.dart';
import '../../services/trip_service.dart';
import '../trip_planning/create_trip_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final TripService _tripService = TripService();
  late Future<List<Trip>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = _tripService.getTrips();
    TripService.tripListRevision.addListener(_reloadTrips);
  }

  @override
  void dispose() {
    TripService.tripListRevision.removeListener(_reloadTrips);
    super.dispose();
  }

  void _reloadTrips() {
    setState(() {
      _tripsFuture = _tripService.getTrips();
    });
  }

  void _createTrip() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreateTripScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Unable to load trips: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          );
        }

        final trips = snapshot.data ?? const <Trip>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Trips',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Create a trip',
                  child: IconButton(
                    onPressed: _createTrip,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final trip in trips) _TripListTile(trip: trip),
          ],
        );
      },
    );
  }
}

class _TripListTile extends StatelessWidget {
  const _TripListTile({required this.trip});

  final Trip trip;

  Color get _statusColor {
    switch (trip.status.toLowerCase()) {
      case 'upcoming':
        return AppTheme.primaryGreen;
      case 'draft':
        return const Color(0xFFFFB23F);
      case 'completed':
        return const Color(0xFFA5A5AD);
      default:
        return AppTheme.textMuted;
    }
  }

  String get _statusLabel {
    switch (trip.status.toLowerCase()) {
      case 'upcoming':
        return 'Upcoming';
      case 'draft':
        return 'Draft';
      case 'completed':
        return 'Completed';
      default:
        return trip.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              trip.imageUrl,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox(
                width: 54,
                height: 54,
                child: ColoredBox(
                  color: Color(0xFFE0E4E6),
                  child: Icon(
                    Icons.landscape_rounded,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.destination,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${trip.dateRange} • ${trip.duration}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _statusLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (trip.status.toLowerCase() == 'completed') {
      return Semantics(
        button: true,
        label: 'Open ${trip.destination} trip memories',
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/trips/${trip.id}/memories', extra: trip),
          child: content,
        ),
      );
    }
    return Semantics(
      button: true,
      label: 'Open ${trip.destination} itinerary',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/trips/${trip.id}', extra: trip),
        child: content,
      ),
    );
  }
}
