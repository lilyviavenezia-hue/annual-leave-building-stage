import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

import 'package:homempage/models/leave_status.dart';

class CalendarGrid extends StatelessWidget {
  final int selectedYear;
  final int currentMonthIndex; // 0 for Jan, 11 for Dec
  final Map<String, DateStatus> dateStatuses;
  final Function(DateTime date) onDateTap;
  final DateTimeRange? selectedDateRange;

  const CalendarGrid({
    super.key,
    required this.selectedYear,
    required this.currentMonthIndex,
    required this.dateStatuses,
    required this.onDateTap,
    this.selectedDateRange,
  });

  /// Helper to get total days in a given month/year
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Helper to get the weekday offset for the 1st of the month
  /// Returns 0 for Monday, 1 for Tuesday, ..., 6 for Sunday
  int _getStartingWeekdayOffset(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    return firstDay.weekday - 1; // DateTime.weekday: Mon = 1, Sun = 7
  }

  @override
  Widget build(BuildContext context) {
    final daysInWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Month numbers in DateTime are 1-indexed (1 to 12)
    final monthNumber = currentMonthIndex + 1;
    final totalDaysInMonth = _getDaysInMonth(selectedYear, monthNumber);
    final startingOffset = _getStartingWeekdayOffset(selectedYear, monthNumber);

    // Total cells required = leading empty offset + actual days in month
    final totalGridCells = startingOffset + totalDaysInMonth;

    return Column(
      children: [
        // Day of Week Header (M T W T F S S)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysInWeek
              .map(
                (d) => Text(
                  d,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),

        // Calendar Grid View
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalGridCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            // Empty placeholder cells before the 1st of the month
            if (index < startingOffset) {
              return const SizedBox.shrink();
            }

            final dayNumber = index - startingOffset + 1;
            final date = DateTime(selectedYear, monthNumber, dayNumber);

            // Format date key as YYYY-MM-DD to match model format
            final dateKey =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

            final status = dateStatuses[dateKey] ?? DateStatus.normal;
            final selectedRange = selectedDateRange;
            final isInSelectedRange =
                selectedRange != null &&
                !date.isBefore(
                  DateTime(
                    selectedRange.start.year,
                    selectedRange.start.month,
                    selectedRange.start.day,
                  ),
                ) &&
                !date.isAfter(
                  DateTime(
                    selectedRange.end.year,
                    selectedRange.end.month,
                    selectedRange.end.day,
                  ),
                );

            return GestureDetector(
              onTap: () => onDateTap(date),
              child: Container(
                decoration: BoxDecoration(
                  color: status.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isInSelectedRange
                      ? Border.all(color: AppTheme.primaryGreen, width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: status.textColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
