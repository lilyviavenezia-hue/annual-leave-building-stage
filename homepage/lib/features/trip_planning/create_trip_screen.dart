import 'package:flutter/material.dart';
import 'package:homempage/core/theme/app_theme.dart';
import 'package:homempage/features/trip_planning/travel_preferences.dart';
import 'package:homempage/features/trip_planning/trip_collaborators_screen.dart';
import 'widgets/budget_range_slider.dart';
import 'widgets/location_dropdown_field.dart';
import 'widgets/travellers_counter_card.dart';
import 'widgets/trip_date_picker_card.dart';
import 'widgets/trip_style_selector.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  bool _isSoloSelected = true;
  String? _selectedFrom;
  String? _selectedTo;
  int _numberOfTravellers = 4;
  RangeValues _budgetRange = const RangeValues(500, 3000);
  DateTimeRange _selectedDates = DateTimeRange(
    start: DateTime(2026, 10, 12),
    end: DateTime(2026, 10, 18),
  );

  Future<void> _handleGroupSelected() async {
    setState(() => _isSoloSelected = false);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TripCollaboratorsScreen(),
      ),
    );

    if (mounted) {
      setState(() => _isSoloSelected = true);
    }
  }

  void _handleNext() {
    if (_isSoloSelected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TravelPreferencesScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TripCollaboratorsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create your trip',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Style Selector
                  TripStyleSelector(
                    isSoloSelected: _isSoloSelected,
                    onSelectSolo: () => setState(() => _isSoloSelected = true),
                    onSelectGroup: _handleGroupSelected,
                  ),
                  const SizedBox(height: 24),

                  // 2. Location Fields
                  const Text(
                    'Destination',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LocationDropdownField(
                    hint: 'From',
                    value: _selectedFrom,
                    onChanged: (val) => setState(() => _selectedFrom = val),
                  ),
                  const SizedBox(height: 12),
                  LocationDropdownField(
                    hint: 'To',
                    value: _selectedTo,
                    onChanged: (val) => setState(() => _selectedTo = val),
                  ),
                  const SizedBox(height: 24),

                  // 3. Travellers Counter
                  TravellersCounterCard(
                    count: _numberOfTravellers,
                    onIncrement: () => setState(() => _numberOfTravellers++),
                    onDecrement: () => setState(() => _numberOfTravellers--),
                  ),
                  const SizedBox(height: 24),

                  // 4. Date Picker
                  TripDatePickerCard(
                    selectedDates: _selectedDates,
                    onDatesSelected: (dates) => setState(() => _selectedDates = dates),
                  ),
                  const SizedBox(height: 24),

                  // 5. Budget Slider
                  BudgetRangeSlider(
                    range: _budgetRange,
                    onChanged: (values) => setState(() => _budgetRange = values),
                  ),
                  const SizedBox(height: 32),

                  // 6. Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.backgroundWhite,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}