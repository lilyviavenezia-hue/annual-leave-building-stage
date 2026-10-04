import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:homempage/models/leave_status.dart';

class CalendarGrid extends StatelessWidget {
  final int selectedYear;
  final int currentMonthIndex;
  final Map<String, DateStatus> dateStatuses;
  final Function(DateTime date) onDateTap;

  const CalendarGrid({
    super.key,
    required this.selectedYear,
    required this.currentMonthIndex,
    required this.dateStatuses,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: daysInWeek
              .map((d) => Text(
                    d,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMuted,
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 35,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - 2;

            if (dayNumber < 1 || dayNumber > 31) {
              return const SizedBox.shrink();
            }

            final date = DateTime(selectedYear, currentMonthIndex + 1, dayNumber);
            final dateKey =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            final status = dateStatuses[dateKey] ?? DateStatus.normal;

            return GestureDetector(
              onTap: () => onDateTap(date),
              child: Container(
                decoration: BoxDecoration(
                  color: status.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
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