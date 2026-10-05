import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../models/attraction.dart';
import '../../models/itinerary.dart';
import '../../models/trip.dart';
import '../../services/itinerary_service.dart';
import '../../services/recommendation_service.dart';
import 'widgets/itinerary_daycards.dart';
import 'widgets/itinerary_side_panel.dart';
import 'widgets/itinerary_calendar_view.dart';
import 'widgets/panel_state.dart';
import 'replan_issue_screen.dart';

class ItineraryOverviewScreen extends StatefulWidget {
  final String itineraryId;
  final int initialDayIndex;
  final Trip? initialTrip;

  const ItineraryOverviewScreen({
    super.key,
    required this.itineraryId,
    this.initialDayIndex = 0,
    this.initialTrip,
  });

  @override
  State<ItineraryOverviewScreen> createState() =>
      _ItineraryOverviewScreenState();
}

class _ItineraryOverviewScreenState extends State<ItineraryOverviewScreen> {
  final ItineraryService _itineraryService = ItineraryService();
  final RecommendationService _recommendationService = RecommendationService();

  late Future<ItineraryOverview> _itineraryFuture;
  late Future<List<ItineraryDetailItem>> _dayItemsFuture;
  late Future<List<Attraction>> _attractionsFuture;

  int _selectedTabIndex = 0;
  PanelState _panelState = PanelState.hidden;
  String _selectedCategory = 'Attractions';
  final Map<int, List<ItineraryDetailItem>> _addedItemsByDay = {};
  final Map<int, Map<String, ItineraryDetailItem>> _movedItemsByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialDayIndex;
    _panelState = widget.initialDayIndex > 0
        ? PanelState.peek
        : PanelState.hidden;
    _itineraryFuture = _itineraryService.getItineraryOverview(
      widget.itineraryId,
    );
    _dayItemsFuture = _itineraryService.getDayDetailItems(
      widget.itineraryId,
      widget.initialDayIndex > 0 ? widget.initialDayIndex : 1,
    );
    _attractionsFuture = _recommendationService.getRecommendedAttractions();
  }

  void _onTabSelected(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
      if (index > 0) {
        _dayItemsFuture = _itineraryService.getDayDetailItems(
          widget.itineraryId,
          index,
        );
        _panelState = PanelState.peek;
      } else {
        _panelState = PanelState.hidden;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: FutureBuilder<ItineraryOverview>(
          future: _itineraryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  'Failed to load itinerary.',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              );
            }

            final data = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(data),
                      const SizedBox(height: 16),
                      _buildFilterTabs(data.durationDays),
                      const SizedBox(height: 12),
                      _buildTripActions(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _selectedTabIndex == 0
                            ? _buildOverviewList(data)
                            : _buildDayTimelineView(),
                      ),
                    ],
                  ),
                  if (_selectedTabIndex > 0 && _panelState != PanelState.hidden)
                    FutureBuilder<List<Attraction>>(
                      future: _attractionsFuture,
                      builder: (context, attractionSnapshot) {
                        return ItinerarySidePanel(
                          panelState: _panelState,
                          availableHeight: constraints.maxHeight,
                          attractions: attractionSnapshot.data ?? [],
                          categories:
                              data.categories ??
                              ['Flights', 'Hotels', 'Attractions', 'Food'],
                          selectedCategory: _selectedCategory,
                          originCode: data.originCode ?? '',
                          destinationCode: data.destinationCode ?? '',
                          originCity: data.originCity ?? '',
                          destinationCity:
                              data.destinationCity ?? data.destination,
                          onPanelStateChanged: (state) =>
                              setState(() => _panelState = state),
                          onCategorySelected: (category) => setState(() {
                            _selectedCategory = category;
                            _panelState = PanelState.expanded;
                          }),
                          onAddToTimeline: _addScheduleItem,
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ItineraryOverview data) {
    final headerTitle = data.title;
    final headerSubtitle =
        '${data.destination} · ${data.dateRange} · ${data.durationDays} days';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headerTitle,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/trips/${widget.itineraryId}/checklist'),
                icon: const Icon(Icons.check_box_outlined, size: 16),
                label: const Text('Checklist'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 7,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              headerSubtitle,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: _replanTrip,
                icon: const Icon(Icons.refresh, size: 17),
                label: const Text(
                  'Replan Trip',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1010),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(14),
            child: IconButton(
              tooltip: 'Financial summary',
              onPressed: () => context.push(
                '/trips/${widget.itineraryId}/financial-summary',
                extra: widget.initialTrip,
              ),
              icon: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 19,
              ),
              constraints: const BoxConstraints.tightFor(width: 42, height: 42),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _replanTrip() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReplanIssueScreen(
          destination: widget.initialTrip?.destination ?? 'Kyoto, Japan',
        ),
      ),
    );
  }

  Widget _buildFilterTabs(int totalDays) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalDays + 1,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          final label = index == 0 ? 'Overview' : 'Day $index';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.grey[200],
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              onSelected: (selected) {
                if (selected) _onTabSelected(index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewList(ItineraryOverview data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: data.days.length,
      itemBuilder: (context, index) {
        return DayOverviewCard(
          dayData: data.days[index],
          isHighlighted: index == 0,
        );
      },
    );
  }

  Widget _buildDayTimelineView() {
    return FutureBuilder<List<ItineraryDetailItem>>(
      future: _dayItemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        final movedItems = _movedItemsByDay[_selectedTabIndex] ?? const {};
        final items =
            [
              ...?snapshot.data?.map((item) => movedItems[item.id] ?? item),
              ...?_addedItemsByDay[_selectedTabIndex],
            ]..sort(
              (first, second) =>
                  _minutesAfterMidnight(first.timeStart)
                      .compareTo(_minutesAfterMidnight(second.timeStart)),
            );
        return ItineraryCalendarView(
          items: items,
          onDrop: _scheduleItemAt,
          onBook: _bookScheduledItem,
        );
      },
    );
  }

  void _addScheduleItem(ItineraryDetailItem item) {
    final initialMinute = _minutesAfterMidnight(item.timeStart);
    _scheduleItemAt(
      item,
      ((initialMinute - 6 * 60) / 60 * 72),
      showConfirmation: false,
    );
    setState(() => _panelState = PanelState.peek);
  }

  void _scheduleItemAt(
    ItineraryDetailItem item,
    double canvasY, {
    bool showConfirmation = true,
  }) {
    final startMinute = (6 * 60 + (canvasY / 72 * 60 / 30).round() * 30)
        .clamp(6 * 60, 23 * 60)
        .toInt();
    final endMinute = (startMinute + _itemDurationMinutes(item))
        .clamp(startMinute + 30, 24 * 60)
        .toInt();
    final scheduledItem = item.copyWith(
      timeStart: _formatScheduleTime(startMinute),
      timeEnd: _formatScheduleTime(endMinute),
    );

    final movedItems = _movedItemsByDay.putIfAbsent(
      _selectedTabIndex,
      () => {},
    );
    final addedItems = _addedItemsByDay.putIfAbsent(
      _selectedTabIndex,
      () => [],
    );

    setState(() {
      _panelState = PanelState.peek;
      final existing = addedItems.indexWhere((entry) => entry.id == item.id);
      if (existing != -1) {
        addedItems[existing] = scheduledItem;
      } else {
        movedItems[item.id] = scheduledItem;
        if (!item.id.startsWith('item_') &&
            !addedItems.any((entry) => entry.id == item.id)) {
          addedItems.add(scheduledItem);
        }
      }
    });
    if (showConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          content: Text(
            '${item.title} scheduled for ${scheduledItem.timeStart}.',
          ),
        ),
      );
    }
  }

  Future<void> _bookScheduledItem(ItineraryDetailItem item) async {
    final querySuffix = switch (item.type) {
      'flight' => 'flight booking',
      'hotel' => 'hotel booking',
      'food' => 'restaurant reservations',
      'attraction' => 'tickets',
      _ => 'booking',
    };
    final uri = item.bookingUrl.isNotEmpty
        ? Uri.tryParse(item.bookingUrl)
        : Uri.https('www.google.com', '/search', {
            'q': '${item.title} ${item.subtitle} $querySuffix',
          });
    final canLaunch = uri != null && await canLaunchUrl(uri);
    if (!mounted) return;
    if (uri == null || !canLaunch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open booking options for ${item.title}.'),
        ),
      );
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open booking options for ${item.title}.'),
        ),
      );
    }
  }

  int _itemDurationMinutes(ItineraryDetailItem item) {
    final durationMatch = RegExp(
      r'(?:(\d+)\s*(?:hr|hour)s?)?\s*(?:(\d+)\s*min(?:ute)?s?)?',
      caseSensitive: false,
    ).firstMatch(item.duration);
    if (durationMatch != null &&
        (durationMatch.group(1) != null || durationMatch.group(2) != null)) {
      final hours = int.tryParse(durationMatch.group(1) ?? '') ?? 0;
      final minutes = int.tryParse(durationMatch.group(2) ?? '') ?? 0;
      return (hours * 60 + minutes).clamp(30, 240).toInt();
    }
    return 60;
  }

  int _minutesAfterMidnight(String time) {
    final match = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*(AM|PM)\s*$',
      caseSensitive: false,
    ).firstMatch(time);
    if (match == null) return 6 * 60;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour == 12) hour = 0;
    if (match.group(3)!.toUpperCase() == 'PM') hour += 12;
    return hour * 60 + minute;
  }

  String _formatScheduleTime(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final meridiem = hour < 12 ? 'AM' : 'PM';
    return '$displayHour:${minute.toString().padLeft(2, '0')} $meridiem';
  }
}
