import 'package:flutter/material.dart';
import 'package:homempage/core/theme/app_theme.dart';

class TripDatePickerCard extends StatelessWidget {
  final DateTimeRange selectedDates;
  final ValueChanged<DateTimeRange> onDatesSelected;

  const TripDatePickerCard({
    super.key,
    required this.selectedDates,
    required this.onDatesSelected,
  });

  @override
  Widget build(BuildContext context) {
    final int dayCount = selectedDates.end
        .difference(selectedDates.start)
        .inDays;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dates',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2025),
              lastDate: DateTime(2030),
              initialDateRange: selectedDates,
            );
            if (picked != null) {
              onDatesSelected(picked);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${selectedDates.start.day} ${months[selectedDates.start.month - 1]} - '
                    '${selectedDates.end.day} ${months[selectedDates.end.month - 1]} '
                    '${selectedDates.end.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '($dayCount days)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
