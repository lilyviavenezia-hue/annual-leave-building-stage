import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/group_trip_summary.dart';
import '../../services/group_summary_service.dart';
import 'widgets/host_action_bar.dart';
import 'widgets/summary_overview_tab.dart';
import 'widgets/summary_segmented_control.dart';
import 'widgets/summary_suggestions_tab.dart';

class TripSummaryScreen extends StatefulWidget {
  final String groupId;

  const TripSummaryScreen({super.key, required this.groupId});

  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen> {
  final GroupSummaryService _summaryService = GroupSummaryService();

  int _selectedTabIndex = 1;
  GroupTripSummary? _tripSummary;
  List<GroupSuggestion> _suggestions = [];
  bool _isLoading = true;
  String _selectedSuggestionCategory = 'Favourites';

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    final summary = await _summaryService.getTripSummary(widget.groupId);
    final suggestions = await _summaryService.getGroupSuggestions(widget.groupId);

    if (!mounted) return;
    setState(() {
      _tripSummary = summary;
      _suggestions = suggestions;
      _isLoading = false;
    });
  }

  Future<void> _handleConfirmedDetailUpdated(String key, String newValue) async {
    await _summaryService.updateConfirmedDetail(
      groupId: widget.groupId,
      key: key,
      value: newValue,
    );
    await _loadSummaryData();
  }

  Future<void> _refreshSummary() async {
    final summary = await _summaryService.getTripSummary(widget.groupId);
    if (mounted) setState(() => _tripSummary = summary);
  }

  void _openPlanningSuggestions(String parameter) {
    setState(() {
      _selectedSuggestionCategory = parameter == 'Accommodation'
          ? 'Stays'
          : 'Flights';
      _selectedTabIndex = 1;
    });
  }

  void _handleReadyPressed() {
    if (mounted) {
      context.go('/trips');
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
          'Trip Summary',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  SummarySegmentedControl(
                    selectedIndex: _selectedTabIndex,
                    onTabChanged: (index) {
                      setState(() => _selectedTabIndex = index);
                      if (index == 0) _refreshSummary();
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _selectedTabIndex == 0
                        ? SummaryOverviewTab(
                            tripSummary: _tripSummary!,
                            onSelectPendingDecision: _openPlanningSuggestions,
                            onTagsUpdated: () => setState(() {}),
                            onConfirmedDetailUpdated: _handleConfirmedDetailUpdated,
                          )
                        : SummarySuggestionsTab(
                          suggestions: _suggestions,
                          groupId: widget.groupId,
                          destinationCity:
                              _tripSummary?.destination ?? 'Kyoto',
                          initialCategory: _selectedSuggestionCategory,
                          onPlanningSelectionChanged: _refreshSummary,
                          ),
                  ),
                  if (_selectedTabIndex == 0 && _tripSummary != null)
                    HostActionBar(
                      tripSummary: _tripSummary!,
                      onReadyPressed: _handleReadyPressed,
                    ),
                ],
              ),
            ),
    );
  }
}
