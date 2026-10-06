import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../itinerary/itinerary_overview_screen.dart';
import '../../models/trip.dart';
import '../../models/travel_preference.dart';
import '../../core/theme/app_theme.dart';
import '../../services/itinerary_service.dart';
import '../../services/preference_service.dart';
import '../../services/trip_service.dart';
import 'trip_planning_screen.dart'
    show DefaultPreferencesOverlay, TripCustomizationSwipeOverlay;
import 'widgets/preference_action_card.dart';
import 'widgets/swipe_instructions_modal.dart';
import 'widgets/voice_input_card.dart';

class TravelPreferencesScreen extends StatefulWidget {
  const TravelPreferencesScreen({
    super.key,
    this.tripDraft,
    this.preferenceService,
  });

  final Trip? tripDraft;
  final PreferenceService? preferenceService;

  @override
  State<TravelPreferencesScreen> createState() =>
      _TravelPreferencesScreenState();
}

class _TravelPreferencesScreenState extends State<TravelPreferencesScreen> {
  late final PreferenceService _preferenceService;
  final TextEditingController _transcriptController = TextEditingController();
  late TravelPreference _travelPreference;

  bool _isLoading = true;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _preferenceService = widget.preferenceService ?? PreferenceService();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _preferenceService.getPreferences();
    if (!mounted) return;
    setState(() {
      _travelPreference = prefs;
      _transcriptController.text = prefs.transcript;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (!_isRecording) {
      final text = _transcriptController.text;
      _transcriptController.text = text.isEmpty
          ? "Prefer authentic local cuisine places."
          : "$text Prefer authentic local cuisine places.";
    }
  }

  void _openDefaultPreferencesOverlay() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          DefaultPreferencesOverlay(transcript: _transcriptController.text),
    );
  }

  Future<void> _openTripCustomizationOverlay() async {
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SwipeInstructionsModal(),
    );

    if (proceed != true || !mounted) return;

    final cards = await _preferenceService.getSwipeCards();
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripCustomizationSwipeOverlay(cards: cards),
    );
  }

  bool _isGenerating = false;

  Future<void> _generateItinerary() async {
    final trip =
        widget.tripDraft ??
        Trip(
          id: 'TRIP_${DateTime.now().millisecondsSinceEpoch}',
          destination: 'Kyoto, Japan',
          dateRange: '12 - 18 October 2026',
          duration: '6 days',
          budget: 'RM 3,000 budget',
          imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1000&auto=format&fit=crop',
          status: 'draft',
          travellerCount: 4,
          plannedBudget: 3000,
        );
    setState(() => _isGenerating = true);
    try {
      final generatedItinerary = await _preferenceService.generateItinerary(
        trip: trip,
        preference: _travelPreference.copyWith(
          transcript: _transcriptController.text.trim(),
        ),
      );
      if (!mounted) return;
      if (generatedItinerary.overview.id != trip.id) {
        throw const FormatException(
          'The generated itinerary does not match the submitted trip.',
        );
      }
      ItineraryService.saveGeneratedItinerary(generatedItinerary);
      final generatedTrip = trip.copyWith(
        estimatedBudget: generatedItinerary.estimatedBudget,
        budgetBreakdown: generatedItinerary.budgetBreakdown,
      );
      await TripService().saveDraft(generatedTrip);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ItineraryOverviewScreen(
            itineraryId: generatedTrip.id,
            initialTrip: generatedTrip.copyWith(status: 'draft'),
            generatedItinerary: generatedItinerary,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to generate itinerary: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Travel preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Voice Recording & Input Box
              VoiceInputCard(
                controller: _transcriptController,
                isRecording: _isRecording,
                onToggleRecording: _toggleRecording,
              ),

              const SizedBox(height: 20),

              // Generate Itinerary Primary Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateItinerary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGenerating)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else ...[
                        const Icon(
                          Icons.star_rate_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            'Generate my itinerary',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Global Default Preferences Option Card
              PreferenceActionCard(
                title: 'Set Default Travel Preferences',
                subtitle: 'Global pace, accessibility & default settings across all trips',
                icon: Icons.settings_outlined,
                onTap: _openDefaultPreferencesOverlay,
              ),

              const SizedBox(height: 12),

              // Trip Swipe Customization Option Card
              PreferenceActionCard(
                title: 'Customize This Trip',
                subtitle: 'Swipe cards to like, dislike, or skip specific activity options',
                icon: Icons.swipe_outlined,
                onTap: _openTripCustomizationOverlay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
