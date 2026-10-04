import 'package:flutter/material.dart';
import 'package:homempage/core/theme/app_theme.dart';

import '../../../models/itinerary.dart';

class DayOverviewCard extends StatelessWidget {
  final ItineraryDayOverview dayData;
  final bool isHighlighted;

  const DayOverviewCard({
    super.key,
    required this.dayData,
    this.isHighlighted = false,
  });

  static const primaryGreen = Color(0xFF67CE67);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? primaryGreen : Colors.grey[300]!,
          width: isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day ${dayData.dayNumber}, ${dayData.dateString} – ${dayData.location}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _buildStopsWithSeparators(dayData.stops),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStopsWithSeparators(List<ItineraryStop> stops) {
    final List<Widget> widgets = [];
    for (int i = 0; i < stops.length; i++) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            stops[i].name,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

      if (i < stops.length - 1) {
        widgets.add(
          Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
        );
      }
    }
    return widgets;
  }
}

class TimelineScheduleCard extends StatelessWidget {
  final ItineraryDetailItem item;
  final VoidCallback onBook;

  const TimelineScheduleCard({
    super.key,
    required this.item,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final bookingLabel = switch (item.type) {
      'flight' => 'Book flight',
      'hotel' => 'Book stay',
      'food' => 'Reserve table',
      'attraction' => 'Get tickets',
      _ => '',
    };

    return Material(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.timeStart,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  item.timeEnd,
                  style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(9, 6, 8, 5),
              decoration: BoxDecoration(
                color: item.timeTagBgColor.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: item.timeTagBgColor, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.drag_indicator,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  if (item.subtitle.isNotEmpty)
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                    ),
                  if (bookingLabel.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: onBook,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2, left: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.open_in_new,
                                size: 12,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                bookingLabel,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
