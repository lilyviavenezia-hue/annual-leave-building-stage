import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../models/group_trip_summary.dart';
import 'suggestion_card.dart';
import 'suggestion_detail.dart';

class SummarySuggestionsTab extends StatefulWidget {
  final List<GroupSuggestion> suggestions;

  const SummarySuggestionsTab({
    super.key,
    required this.suggestions,
  });

  @override
  State<SummarySuggestionsTab> createState() => _SummarySuggestionsTabState();
}

class _SummarySuggestionsTabState extends State<SummarySuggestionsTab> {
  String _selectedCategoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Attractions', 'Restaurants', 'Stays'];

    final filteredSuggestions = _selectedCategoryFilter == 'All'
        ? widget.suggestions
        : widget.suggestions
            .where((item) =>
                item.category.toLowerCase() == _selectedCategoryFilter.toLowerCase())
            .toList();

    return Column(
      children: [
        // Filter Chips Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategoryFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen,
                  backgroundColor: AppTheme.cardBackground,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  onSelected: (_) => setState(() => _selectedCategoryFilter = cat),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide.none,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // Suggestions List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            itemCount: filteredSuggestions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = filteredSuggestions[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SuggestionDetailModal(suggestion: item),
                    ),
                  );
                },
                child: SuggestionCard(suggestion: item),
              );
            },
          ),
        ),
      ],
    );
  }
}