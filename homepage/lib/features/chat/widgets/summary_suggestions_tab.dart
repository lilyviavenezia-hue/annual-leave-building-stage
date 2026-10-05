import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../models/attraction.dart';
import '../../../models/food_option.dart';
import '../../../models/group_trip_summary.dart';
import '../../../models/hotel.dart';
import '../../../services/food_service.dart';
import '../../../services/hotel_service.dart';
import '../../../services/recommendation_service.dart';
import 'suggestion_card.dart';
import 'suggestion_detail.dart';

class SummarySuggestionsTab extends StatefulWidget {
  final List<GroupSuggestion> suggestions;
  final String destinationCity;

  const SummarySuggestionsTab({
    super.key,
    required this.suggestions,
    this.destinationCity = 'Kyoto',
  });

  @override
  State<SummarySuggestionsTab> createState() => _SummarySuggestionsTabState();
}

class _SummarySuggestionsTabState extends State<SummarySuggestionsTab> {
  String _selectedCategoryFilter = 'All';
  List<Attraction> _attractions = [];
  List<FoodOption> _foods = [];
  List<HotelOption> _hotels = [];
  bool _isLoadingItems = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryItems();
  }

  @override
  void didUpdateWidget(covariant SummarySuggestionsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationCity != widget.destinationCity) {
      _loadCategoryItems();
    }
  }

  Future<void> _loadCategoryItems() async {
    setState(() => _isLoadingItems = true);
    final results = await Future.wait<dynamic>([
      RecommendationService().getRecommendedAttractions(),
      FoodService().getRecommendedEats(widget.destinationCity),
      HotelService().searchHotels(widget.destinationCity),
    ]);
    if (!mounted) return;
    setState(() {
      _attractions = results[0] as List<Attraction>;
      _foods = results[1] as List<FoodOption>;
      _hotels = results[2] as List<HotelOption>;
      _isLoadingItems = false;
    });
  }

  void _toggleSuggestionSaved(GroupSuggestion suggestion) {
    setState(() => suggestion.isSaved = !suggestion.isSaved);
  }

  void _toggleAttractionSaved(Attraction attraction) {
    setState(() => attraction.isFavourite = !attraction.isFavourite);
  }

  void _toggleFoodSaved(FoodOption food) {
    setState(() => food.isFavourite = !food.isFavourite);
  }

  void _toggleHotelSaved(HotelOption hotel) {
    setState(() => hotel.isFavourite = !hotel.isFavourite);
  }

  Widget _buildFavouriteButton({
    required bool isFavourite,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        isFavourite ? Icons.favorite : Icons.favorite_border,
        size: 16,
      ),
      label: Text(isFavourite ? 'Saved' : 'Favourite'),
      style: ElevatedButton.styleFrom(
        foregroundColor: isFavourite ? Colors.white : AppTheme.primaryGreen,
        backgroundColor: isFavourite ? AppTheme.primaryGreen : Colors.white,
        side: const BorderSide(color: AppTheme.primaryGreen),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAttractionCard(Attraction item) {
    final isSaved = item.isFavourite;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: Colors.grey[300],
                child: const Icon(Icons.place),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.location,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Text(
                  item.price,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildFavouriteButton(
            isFavourite: isSaved,
            onPressed: () => _toggleAttractionSaved(item),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodOption item) {
    final isSaved = item.isFavourite;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.cuisineType} • ${item.priceTier}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: Color(0xFFFBBC04)),
                    const SizedBox(width: 3),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildFavouriteButton(
            isFavourite: isSaved,
            onPressed: () => _toggleFoodSaved(item),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(HotelOption item) {
    final isSaved = item.isFavourite;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.hotel_outlined,
              color: AppTheme.primaryGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.location,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: Color(0xFFFBBC04)),
                    const SizedBox(width: 3),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.pricePerNightFormatted,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildFavouriteButton(
            isFavourite: isSaved,
            onPressed: () => _toggleHotelSaved(item),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedFavouriteList() {
    final attractions = _attractions.where((item) => item.isFavourite).toList();
    final foods = _foods.where((item) => item.isFavourite).toList();
    final hotels = _hotels.where((item) => item.isFavourite).toList();

    final items = [
      ...attractions.map((item) => {'type': 'attraction', 'item': item}),
      ...foods.map((item) => {'type': 'food', 'item': item}),
      ...hotels.map((item) => {'type': 'hotel', 'item': item}),
    ];

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No favourite suggestions yet.'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = items[index];
        final type = entry['type'] as String;
        if (type == 'attraction') {
          return _buildAttractionCard(entry['item'] as Attraction);
        }
        if (type == 'food') {
          return _buildFoodCard(entry['item'] as FoodOption);
        }
        return _buildHotelCard(entry['item'] as HotelOption);
      },
    );
  }

  Widget _buildListFromCategory(String category) {
    if (_isLoadingItems) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (category) {
      case 'Attractions':
        if (_attractions.isEmpty) {
          return const Center(
            child: Text('No attraction suggestions available.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: _attractions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _buildAttractionCard(_attractions[index]),
        );
      case 'Restaurants':
        if (_foods.isEmpty) {
          return const Center(
            child: Text('No restaurant suggestions available.'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: _foods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildFoodCard(_foods[index]),
        );
      case 'Stays':
        if (_hotels.isEmpty) {
          return const Center(child: Text('No stay suggestions available.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: _hotels.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildHotelCard(_hotels[index]),
        );
      case 'Favourites':
        return _buildCombinedFavouriteList();
      case 'All':
      default:
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          itemCount: widget.suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = widget.suggestions[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SuggestionDetailModal(suggestion: item),
                  ),
                );
              },
              child: SuggestionCard(
                suggestion: item,
                onToggleFavorite: () => _toggleSuggestionSaved(item),
              ),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Attractions',
      'Restaurants',
      'Stays',
      'Favourites',
    ];

    return Column(
      children: [
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
                  onSelected: (_) =>
                      setState(() => _selectedCategoryFilter = cat),
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
        Expanded(child: _buildListFromCategory(_selectedCategoryFilter)),
      ],
    );
  }
}
