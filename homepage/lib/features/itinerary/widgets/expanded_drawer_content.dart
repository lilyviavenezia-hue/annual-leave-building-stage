import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/attraction.dart';
import '../../../../models/flight.dart';
import '../../../../models/food_option.dart';
import '../../../../models/hotel.dart';
import '../../../../models/itinerary.dart';
import 'attraction_list_view.dart';
import 'flight_comparison_view.dart';
import 'recommended_eats_view.dart';
import 'hotel_comparison_view.dart';
import 'panel_state.dart';

class ExpandedDrawerContent extends StatelessWidget {
  final String destinationCity;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<PanelState> onPanelStateChanged;
  final ValueChanged<String> onCategorySelected;
  final String originCity;
  final String originCode;
  final String destinationCode;
  final Future<List<FlightOption>> flightsFuture;
  final Future<List<FlightDateChip>> dateChipsFuture;
  final Future<List<HotelOption>> hotelsFuture;
  final Future<List<FoodOption>> foodFuture; // Defined here
  final List<Attraction> attractions;
  final ValueChanged<ItineraryDetailItem> onAddToTimeline;

  const ExpandedDrawerContent({
    super.key,
    required this.destinationCity,
    required this.selectedCategory,
    required this.categories,
    required this.onPanelStateChanged,
    required this.onCategorySelected,
    required this.originCity,
    required this.originCode,
    required this.destinationCode,
    required this.flightsFuture,
    required this.dateChipsFuture,
    required this.hotelsFuture,
    required this.foodFuture, // Required in constructor
    required this.attractions,
    required this.onAddToTimeline,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = switch (selectedCategory) {
      'Flights' => 'Compare Flights',
      'Hotels' => 'Compare Hotels',
      'Food' => 'Recommended Eats',
      _ => '$destinationCity Sights',
    };

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => onPanelStateChanged(PanelState.peek),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 36,
                  ),
                ),
                Expanded(
                  child: Text(
                    titleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onPanelStateChanged(PanelState.hidden),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(34, 36),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (selectedCategory) {
      case 'Flights':
        return FlightComparisonView(
          originCity: originCity,
          originCode: originCode,
          destinationCity: destinationCity,
          destinationCode: destinationCode,
          dateChipsFuture: dateChipsFuture,
          flightsFuture: flightsFuture,
          onAddToTimeline: onAddToTimeline,
        );
      case 'Hotels':
        return HotelComparisonView(
          destinationCity: destinationCity,
          hotelsFuture: hotelsFuture,
          onAddToTimeline: onAddToTimeline,
        );
      case 'Food':
        return RecommendedEatsScreen(
          destinationCity: destinationCity,
          foodFuture: foodFuture, // Passed down cleanly
          onAddToTimeline: onAddToTimeline,
        );
      default:
        return AttractionListView(
          attractions: attractions,
          onAddToTimeline: onAddToTimeline,
        );
    }
  }
}
