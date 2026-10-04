import 'package:flutter/material.dart';

import '../../../models/attraction.dart';
import '../../../models/flight.dart';
import '../../../models/food_option.dart';
import '../../../models/hotel.dart';
import '../../../models/itinerary.dart';
import '../../../services/flight_service.dart';
import '../../../services/food_service.dart';
import '../../../services/hotel_service.dart';
import 'expanded_drawer_content.dart';
import 'panel_state.dart';
import 'peek_drawer_content.dart';

class ItinerarySidePanel extends StatefulWidget {
  final PanelState panelState;
  final List<Attraction> attractions;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<PanelState> onPanelStateChanged;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<ItineraryDetailItem> onAddToTimeline;
  final double availableHeight;
  final String originCode;
  final String destinationCode;
  final String originCity;
  final String destinationCity;

  const ItinerarySidePanel({
    super.key,
    required this.panelState,
    required this.attractions,
    required this.categories,
    required this.selectedCategory,
    required this.onPanelStateChanged,
    required this.onCategorySelected,
    required this.onAddToTimeline,
    required this.availableHeight,
    required this.originCode,
    required this.destinationCode,
    required this.originCity,
    required this.destinationCity,
  });

  @override
  State<ItinerarySidePanel> createState() => _ItinerarySidePanelState();
}

class _ItinerarySidePanelState extends State<ItinerarySidePanel> {
  final FlightService _flightService = FlightService();
  final HotelService _hotelService = HotelService();
  final FoodService _foodService = FoodService();

  late Future<List<FlightOption>> _flightsFuture;
  late Future<List<FlightDateChip>> _dateChipsFuture;
  late Future<List<HotelOption>> _hotelsFuture;
  late Future<List<FoodOption>> _foodFuture;
  double _verticalDragDistance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant ItinerarySidePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationCity != widget.destinationCity ||
        oldWidget.originCode != widget.originCode ||
        oldWidget.destinationCode != widget.destinationCode) {
      _loadData();
    }
  }

  void _loadData() {
    _flightsFuture = _flightService.searchFlights(
      widget.originCode,
      widget.destinationCode,
    );
    _dateChipsFuture = _flightService.getFlightDateChips(
      widget.originCode,
      widget.destinationCode,
    );
    _hotelsFuture = _hotelService.searchHotels(widget.destinationCity);
    _foodFuture = _foodService.getRecommendedEats(widget.destinationCity);
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.panelState == PanelState.expanded;
    final sheetHeight = isExpanded ? widget.availableHeight * 0.6 : 74.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      left: 0,
      right: 0,
      bottom: 0,
      height: sheetHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            GestureDetector(
              key: const ValueKey('itinerary-panel-handle'),
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _verticalDragDistance = 0,
              onVerticalDragUpdate: (details) {
                _verticalDragDistance += details.delta.dy;
              },
              onTap: () => widget.onPanelStateChanged(
                isExpanded ? PanelState.peek : PanelState.expanded,
              ),
              onVerticalDragEnd: (details) {
                _handleVerticalDragEnd(details);
              },
              child: SizedBox(
                height: 28,
                width: double.infinity,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _verticalDragDistance = 0,
              onVerticalDragUpdate: (details) {
                _verticalDragDistance += details.delta.dy;
              },
              onVerticalDragEnd: _handleVerticalDragEnd,
              child: PeekDrawerContent(
                categories: widget.categories,
                selectedCategory: widget.selectedCategory,
                onCategorySelected: widget.onCategorySelected,
              ),
            ),
            if (isExpanded)
              Expanded(
                child: ExpandedDrawerContent(
                  destinationCity: widget.destinationCity,
                  selectedCategory: widget.selectedCategory,
                  categories: widget.categories,
                  onPanelStateChanged: widget.onPanelStateChanged,
                  onCategorySelected: widget.onCategorySelected,
                  originCity: widget.originCity,
                  originCode: widget.originCode,
                  destinationCode: widget.destinationCode,
                  flightsFuture: _flightsFuture,
                  dateChipsFuture: _dateChipsFuture,
                  hotelsFuture: _hotelsFuture,
                  foodFuture: _foodFuture,
                  attractions: widget.attractions,
                  onAddToTimeline: widget.onAddToTimeline,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -100 || _verticalDragDistance < -30) {
      widget.onPanelStateChanged(PanelState.expanded);
    } else if (velocity > 100 || _verticalDragDistance > 30) {
      widget.onPanelStateChanged(PanelState.peek);
    }
    _verticalDragDistance = 0;
  }
}
