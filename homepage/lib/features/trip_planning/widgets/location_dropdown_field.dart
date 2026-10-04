import 'package:flutter/material.dart';
import 'package:homempage/core/theme/app_theme.dart';

class LocationDropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String> locations;
  final List<String>? options;

  const LocationDropdownField({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.locations = const [
      'Kuala Lumpur',
      'Penang',
      'Ipoh',
      'Langkawi',
      'Tokyo',
    ],
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppTheme.textMuted),
              const SizedBox(width: 12),
              Text(
                hint,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
              ),
            ],
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textMuted,
          ),
          items: (options ?? locations)
              .map(
                (loc) => DropdownMenuItem(
                  value: loc,
                  child: Text(
                    loc,
                    style: const TextStyle(color: AppTheme.textDark),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
