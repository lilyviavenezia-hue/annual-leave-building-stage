import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../models/group_trip_summary.dart';

class SummaryOverviewTab extends StatelessWidget {
  final GroupTripSummary tripSummary;
  final VoidCallback onSelectPendingDecision;
  final VoidCallback onTagsUpdated;
  final Function(String key, String newValue) onConfirmedDetailUpdated;

  const SummaryOverviewTab({
    super.key,
    required this.tripSummary,
    required this.onSelectPendingDecision,
    required this.onTagsUpdated,
    required this.onConfirmedDetailUpdated,
  });

  IconData _getCategoryIcon(String key) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('budget')) return Icons.help_outline;
    if (lowerKey.contains('accommodation')) return Icons.hotel_outlined;
    if (lowerKey.contains('destination')) return Icons.location_on_outlined;
    if (lowerKey.contains('date')) return Icons.calendar_today_outlined;
    if (lowerKey.contains('transport')) return Icons.directions_bus_outlined;
    if (lowerKey.contains('friend') ||
        lowerKey.contains('traveller') ||
        lowerKey.contains('traveler')) {
      return Icons.people_outline;
    }
    return Icons.check_circle_outline;
  }

  void _showEditDetailSheet(
    BuildContext context,
    String key,
    String currentValue,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit $key',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Confirmed $key',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final newValue = controller.text.trim();
                    if (newValue.isNotEmpty) {
                      onConfirmedDetailUpdated(key, newValue);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Planning Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Planning status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tripSummary.pendingDecisions.length} TO DECIDE',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Needs your group to decide · tap any item to mark resolved',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),

          // B. Interactive Grid combining Pending (Yellow) & Confirmed (Green) Items
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.9,
            children: [
              // Pending Decisions (Yellow Tiles -> Tapping opens Suggestions)
              ...tripSummary.pendingDecisions.map((decision) {
                return GestureDetector(
                  onTap: onSelectPendingDecision,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            size: 12,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          decision,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Confirmed Details (Green Tiles with Pencil Icon -> Tapping opens Edit Sheet)
              ...tripSummary.confirmedDetails.entries.map((entry) {
                return GestureDetector(
                  onTap: () =>
                      _showEditDetailSheet(context, entry.key, entry.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA5D6A7)),
                    ),
                    child: Stack(
                      children: [
                        // Edit Indicator Pencil Icon on Top Right
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getCategoryIcon(entry.key),
                                size: 14,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                entry.key,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                entry.value,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 28),

          // C. Group Preferences Section
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),

          _buildEditablePreferences(tripSummary.preferenceTags),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildEditablePreferences(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...tags.map(
          (tag) => Chip(
            label: Text(
              tag,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.cardBackground,
            onDeleted: () {
              tags.remove(tag);
              onTagsUpdated();
            },
            deleteIcon: const Icon(
              Icons.close,
              size: 16,
              color: AppTheme.textMuted,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide.none,
            ),
          ),
        ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 16, color: AppTheme.primaryGreen),
          label: const Text(
            'Add',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.cardBackground,
          onPressed: () {
            tags.add('New Preference');
            onTagsUpdated();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide.none,
          ),
        ),
      ],
    );
  }
}
