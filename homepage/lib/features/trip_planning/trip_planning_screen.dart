import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/trip_customization.dart';

class TripCustomizationSwipeOverlay extends StatefulWidget {
  final List<PreferenceCardItem> cards;
  final void Function(PreferenceCardItem card, DismissDirection direction)? onCardSwiped;

  const TripCustomizationSwipeOverlay({
    super.key,
    required this.cards,
    this.onCardSwiped,
  });

  @override
  State<TripCustomizationSwipeOverlay> createState() =>
      _TripCustomizationSwipeOverlayState();
}

class _TripCustomizationSwipeOverlayState
    extends State<TripCustomizationSwipeOverlay> {
  int _currentIndex = 0;

  void _onSwipe(DismissDirection direction) {
    if (_currentIndex < widget.cards.length) {
      widget.onCardSwiped?.call(widget.cards[_currentIndex], direction);
    }
    setState(() {
      _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height * 0.82;

    return Container(
      height: availableHeight,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header with Title & Close Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customize for this trip',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.primaryGreen),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // Progress indicator text
          if (_currentIndex < widget.cards.length)
            Text(
              'Question ${_currentIndex + 1} of ${widget.cards.length}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 12),

          // Swipe Card Stack Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _currentIndex < widget.cards.length
                  ? Dismissible(
                      key: ValueKey(widget.cards[_currentIndex].id),
                      onDismissed: _onSwipe,
                      child: _SwipeCardWidget(
                        card: widget.cards[_currentIndex],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'All preferences customized!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeCardWidget extends StatelessWidget {
  final PreferenceCardItem card;

  const _SwipeCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image with Error Handling
            Positioned.fill(
              child: Image.network(
                card.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Unable to load image',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),

            // Card Content
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${card.category} · ${card.tag}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DefaultPreferencesOverlay extends StatefulWidget {
  final String transcript;

  const DefaultPreferencesOverlay({
    super.key,
    required this.transcript,
  });

  @override
  State<DefaultPreferencesOverlay> createState() =>
      _DefaultPreferencesOverlayState();
}

class _DefaultPreferencesOverlayState
    extends State<DefaultPreferencesOverlay> {
  final Map<String, List<String>> _categories = {
    'Dietary': ['Vegetarian', 'Vegan', 'Halal', 'Gluten-Free', 'No Seafood'],
    'Pace': ['Relaxed', 'Moderate', 'Fast-paced'],
    'Interests': ['Culture & History', 'Nature', 'Shopping', 'Foodie', 'Nightlife'],
  };

  // Pace should be single-select; others are multi-select
  final Set<String> _singleSelectCategories = {'Pace'};
  final Set<String> _selectedPreferences = {'Halal', 'Moderate', 'Culture & History', 'Foodie'};

  void _togglePreference(String category, String pref, bool selected) {
    setState(() {
      if (_singleSelectCategories.contains(category)) {
        if (selected) {
          // Remove any previously selected option from this category
          _selectedPreferences.removeAll(_categories[category]!);
          _selectedPreferences.add(pref);
        }
      } else {
        if (selected) {
          _selectedPreferences.add(pref);
        } else {
          _selectedPreferences.remove(pref);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: mediaQuery.viewInsets.bottom + 20,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Default Travel Preferences',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Scrollable Preferences
          Expanded(
            child: ListView(
              children: [
                if (widget.transcript.isNotEmpty) ...[
                  Text(
                    'Voice/Text Notes:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.transcript,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                ..._categories.entries.map((entry) {
                  final categoryName = entry.key;
                  final options = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: options.map((pref) {
                          final isSelected = _selectedPreferences.contains(pref);
                          return FilterChip(
                            label: Text(pref),
                            selected: isSelected,
                            onSelected: (selected) {
                              _togglePreference(categoryName, pref, selected);
                            },
                            selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                            checkmarkColor: AppTheme.primaryGreen,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Save Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedPreferences.toList());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Save Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}