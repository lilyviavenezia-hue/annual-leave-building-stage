import 'package:flutter/material.dart';

import '../../../../models/itinerary.dart';
import 'itinerary_daycards.dart';

class ItineraryCalendarView extends StatefulWidget {
  const ItineraryCalendarView({
    super.key,
    required this.items,
    required this.onDrop,
    required this.onBook,
  });

  final List<ItineraryDetailItem> items;
  final void Function(ItineraryDetailItem item, double canvasY) onDrop;
  final ValueChanged<ItineraryDetailItem> onBook;

  @override
  State<ItineraryCalendarView> createState() => _ItineraryCalendarViewState();
}

class _ItineraryCalendarViewState extends State<ItineraryCalendarView> {
  static const int _firstHour = 6;
  static const int _lastHour = 24;
  static const double _hourHeight = 72;

  final GlobalKey _calendarCanvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final canvasHeight = (_lastHour - _firstHour) * _hourHeight;
    return DragTarget<ItineraryDetailItem>(
      key: const ValueKey('itinerary-timeline-drop-target'),
      hitTestBehavior: HitTestBehavior.translucent,
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final renderObject = _calendarCanvasKey.currentContext
            ?.findRenderObject();
        if (renderObject is! RenderBox) return;
        final localPosition = renderObject.globalToLocal(details.offset);
        widget.onDrop(details.data, localPosition.dy);
      },
      builder: (context, candidates, rejected) => SingleChildScrollView(
        key: const ValueKey('itinerary-calendar-scroll-view'),
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            key: _calendarCanvasKey,
            height: canvasHeight,
            width: constraints.maxWidth,
            child: Stack(
              children: [
                for (var hour = _firstHour; hour < _lastHour; hour++)
                  Positioned(
                    top: (hour - _firstHour) * _hourHeight,
                    left: 0,
                    right: 0,
                    height: _hourHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 66,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, top: 2),
                            child: Text(
                              _formatHour(hour),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF78808A),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFE5E8EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  left: 66,
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                ),
                for (final item in widget.items)
                  _buildCalendarEvent(item, constraints.maxWidth - 74),
                if (candidates.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 76,
                    right: 16,
                    child: IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7EE)
                              .withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF31C45B)),
                        ),
                        child: const Text(
                          'Drop to schedule this activity',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF16863A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarEvent(ItineraryDetailItem item, double eventWidth) {
    final startMinute = _minuteOfDay(item.timeStart);
    final endMinute = _minuteOfDay(item.timeEnd);
    final top = ((startMinute - _firstHour * 60) / 60 * _hourHeight)
        .clamp(0.0, double.infinity)
        .toDouble();
    final height = (((endMinute - startMinute) / 60) * _hourHeight)
        .clamp(66.0, 180.0)
        .toDouble();

    return Positioned(
      key: ValueKey('calendar-event-${item.id}'),
      top: top,
      left: 74,
      right: 8,
      height: height,
      child: Draggable<ItineraryDetailItem>(
        data: item,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: eventWidth,
            height: height,
            child: TimelineScheduleCard(item: item, onBook: () {}),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: TimelineScheduleCard(item: item, onBook: () {}),
        ),
        child: TimelineScheduleCard(
          item: item,
          onBook: () => widget.onBook(item),
        ),
      ),
    );
  }

  static String _formatHour(int hour) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final meridiem = hour < 12 ? 'AM' : 'PM';
    return '$displayHour $meridiem';
  }

  static int _minuteOfDay(String time) {
    final match = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*(AM|PM)\s*$',
      caseSensitive: false,
    ).firstMatch(time);
    if (match == null) return _firstHour * 60;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3)!.toUpperCase() == 'PM';
    if (hour == 12) hour = 0;
    if (isPm) hour += 12;
    return hour * 60 + minute;
  }
}
