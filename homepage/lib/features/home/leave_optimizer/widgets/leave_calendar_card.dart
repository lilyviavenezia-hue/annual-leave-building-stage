import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/leave_status.dart';
import 'calendar_grid.dart';

class LeaveCalendarCard extends StatelessWidget {
  final int selectedYear;
  final int currentMonthIndex;
  final Map<String, DateStatus> dateStatuses;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<DateTime> onDateTap;
  final void Function(int year, int monthIndex) onMonthChanged;

  const LeaveCalendarCard({
    super.key,
    required this.selectedYear,
    required this.currentMonthIndex,
    required this.dateStatuses,
    required this.onDateTap,
    required this.onMonthChanged,
    this.selectedDateRange,
  });

  @override
  Widget build(BuildContext context) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final monthPrefix =
        '$selectedYear-${(currentMonthIndex + 1).toString().padLeft(2, '0')}';
    final publicHolidayCount = dateStatuses.entries
        .where(
          (entry) =>
              entry.key.startsWith(monthPrefix) &&
              entry.value == DateStatus.holiday,
        )
        .length;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${months[currentMonthIndex]} $selectedYear',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.badgeGreenLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$publicHolidayCount Public Holiday${publicHolidayCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              _buildLegendItem('Busy', AppTheme.statusBusyBg),
              _buildLegendItem('Holiday', AppTheme.statusHolidayBg),
              _buildLegendItem('Annual Leave', AppTheme.statusAnnualLeaveBg),
              _buildLegendItem('Recommended', AppTheme.statusRecommendedBg),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity;
              if (velocity == null || velocity == 0) return;
              final month = DateTime(
                selectedYear,
                currentMonthIndex + 1 + (velocity < 0 ? 1 : -1),
              );
              onMonthChanged(month.year, month.month - 1);
            },
            child: CalendarGrid(
              selectedYear: selectedYear,
              currentMonthIndex: currentMonthIndex,
              dateStatuses: dateStatuses,
              selectedDateRange: selectedDateRange,
              onDateTap: onDateTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
      ),
    ],
  );
}
