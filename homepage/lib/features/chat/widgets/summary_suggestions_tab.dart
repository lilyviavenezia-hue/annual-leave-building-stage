import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/attraction.dart';
import '../../../models/food_option.dart';
import '../../../models/flight.dart';
import '../../../models/group_trip_summary.dart';
import '../../../models/hotel.dart';
import '../../../services/food_service.dart';
import '../../../services/flight_service.dart';
import '../../../services/hotel_service.dart';
import '../../../services/recommendation_service.dart';
import '../../../services/favourites_service.dart';
import '../../../services/group_summary_service.dart';
import 'suggestion_detail.dart';

class SummarySuggestionsTab extends StatefulWidget {
  final List<GroupSuggestion> suggestions;
  final String destinationCity;
  final String groupId;
  final String initialCategory;
  final VoidCallback? onPlanningSelectionChanged;

  const SummarySuggestionsTab({
    super.key,
    required this.suggestions,
    required this.groupId,
    this.destinationCity = 'Kyoto',
    this.initialCategory = 'Favourites',
    this.onPlanningSelectionChanged,
  });

  @override
  State<SummarySuggestionsTab> createState() => _SummarySuggestionsTabState();
}

class _SummarySuggestionsTabState extends State<SummarySuggestionsTab> {
  late String _selectedCategoryFilter = widget.initialCategory;
  List<Attraction> _attractions = [];
  List<FoodOption> _foods = [];
  List<HotelOption> _hotels = [];
  List<FlightOption> _flights = [];
  final SuggestionFavoritesService _favoritesService =
      SuggestionFavoritesService();
  final GroupSummaryService _summaryService = GroupSummaryService();
  bool _isLoadingItems = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryItems();
  }

  @override
  void didUpdateWidget(covariant SummarySuggestionsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      _selectedCategoryFilter = widget.initialCategory;
    }
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
      FlightService().getFlights(),
    ]);
    final selections = await _summaryService.getPlanningSelections(widget.groupId);
    if (!mounted) return;
    setState(() {
      _attractions = results[0] as List<Attraction>;
      _foods = results[1] as List<FoodOption>;
      _hotels = results[2] as List<HotelOption>;
      _flights = results[3] as List<FlightOption>;
      for (final item in [..._attractions, ..._foods, ..._hotels, ..._flights]) {
        final key = _favouriteKey(item);
        if (item is HotelOption) {
          item.isFavourite = selections['Accommodation']!.contains(item.id);
        } else if (item is FlightOption) {
          item.isFavourite = selections['Transport']!.contains(item.id);
        } else if (_favoritesService.isFavorite(key) != null) {
          final saved = _favoritesService.isFavorite(key)!;
          _setItemFavourite(item, saved);
        } else {
          _favoritesService.setFavorite(key, _itemFavourite(item));
        }
      }
      _isLoadingItems = false;
    });
  }

  void _toggleAttractionSaved(Attraction attraction) => _toggleItemFavourite(attraction);
  void _toggleFoodSaved(FoodOption food) => _toggleItemFavourite(food);
  void _toggleHotelSaved(HotelOption hotel) => _toggleItemFavourite(hotel);
  void _toggleFlightSaved(FlightOption flight) => _toggleItemFavourite(flight);

  String _favouriteKey(Object item) => switch (item) {
    Attraction value => 'attraction:${value.id}',
    FoodOption value => 'food:${value.id}',
    HotelOption value => 'hotel:${value.id}',
    FlightOption value => 'flight:${value.id}',
    _ => throw ArgumentError.value(item, 'item', 'Unsupported suggestion'),
  };

  bool _itemFavourite(Object item) => switch (item) {
    Attraction value => value.isFavourite,
    FoodOption value => value.isFavourite,
    HotelOption value => value.isFavourite,
    FlightOption value => value.isFavourite,
    _ => false,
  };

  void _setItemFavourite(Object item, bool isFavourite) {
    switch (item) {
      case Attraction value:
        value.isFavourite = isFavourite;
        break;
      case FoodOption value:
        value.isFavourite = isFavourite;
        break;
      case HotelOption value:
        value.isFavourite = isFavourite;
        break;
      case FlightOption value:
        value.isFavourite = isFavourite;
        break;
    }
  }

  Future<void> _toggleItemFavourite(Object item) async {
    final category = item is HotelOption
        ? 'Accommodation'
        : item is FlightOption
        ? 'Transport'
        : null;
    final isSaved = !_itemFavourite(item);
    setState(() {
      final key = _favouriteKey(item);
      _setItemFavourite(item, isSaved);
      if (category == null) _favoritesService.setFavorite(key, isSaved);
    });
    if (category != null) {
      await _summaryService.setPlanningOptionSelected(
        groupId: widget.groupId,
        category: category,
        optionId: item is HotelOption ? item.id : (item as FlightOption).id,
        selected: isSaved,
      );
      widget.onPlanningSelectionChanged?.call();
    }
  }

  _SuggestionEntry _entryFor(Object item) => switch (item) {
    Attraction value => _SuggestionEntry(item: value, title: value.title, imageUrl: value.imageUrl, category: 'Attraction', details: [
      DetailField('Highlights', value.tags.join(' · ')), DetailField('Hours', value.openingHours), DetailField('Location', value.location), DetailField('Fee', value.price), DetailField('Rating', '${value.rating.toStringAsFixed(1)} / 5'),
    ]),
    FoodOption value => _SuggestionEntry(item: value, title: value.name, imageUrl: value.imageUrl, category: 'Restaurant', details: [
      DetailField('Cuisine', value.cuisineType), DetailField('Menu', value.menuItems.join(' · ')), DetailField('Price', value.price), DetailField('Hours', value.openingHours), DetailField('Location', value.location), DetailField('About', value.description), DetailField('Rating', '${value.rating.toStringAsFixed(1)} / 5 · ${value.reviewCount} reviews'),
    ]),
    HotelOption value => _SuggestionEntry(item: value, title: value.name, imageUrl: value.imageUrl, category: 'Stay', details: [
      DetailField('Rooms', value.roomTypes.join(' · ')), DetailField('Amenities', value.amenities.join(' · ')), DetailField('Price', value.pricePerNightFormatted), DetailField('Rating', '${value.rating.toStringAsFixed(1)} / 5'), DetailField('Check-in', value.checkInTime), DetailField('Check-out', value.checkOutTime), DetailField('Location', value.location),
    ]),
    FlightOption value => _SuggestionEntry(item: value, title: value.airlineName, imageUrl: value.airlineLogoUrl, category: 'Flight', details: [
      DetailField('Airline', value.airlineName), DetailField('Route', value.route), DetailField('Times', '${value.departureTime} – ${value.arrivalTime}'), DetailField('Duration', value.duration), DetailField('Stops', value.stops), DetailField('Baggage', value.baggage), DetailField('Fare', value.priceFormatted),
    ]),
    _ => throw ArgumentError.value(item, 'item', 'Unsupported suggestion'),
  };

  void _showItemDetail(_SuggestionEntry entry) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SuggestionDetailPage(
      title: entry.title, imageUrl: entry.imageUrl, category: entry.category, details: entry.details,
      isFavourite: _itemFavourite(entry.item), onToggleFavourite: () => _toggleItemFavourite(entry.item),
    )));
  }

  Widget _tappableCard(Widget child, Object item) => Material(
    color: Colors.transparent,
    child: InkWell(onTap: () => _showItemDetail(_entryFor(item)), borderRadius: BorderRadius.circular(16), child: child),
  );
  Widget _buildFavouriteButton({
    required bool isFavourite,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isFavourite ? 'Saved' : 'Favourite',
      icon: Icon(isFavourite ? Icons.favorite : Icons.favorite_border),
      style: IconButton.styleFrom(
        foregroundColor: isFavourite ? Colors.white : AppTheme.primaryGreen,
        backgroundColor: isFavourite ? AppTheme.primaryGreen : Colors.white,
        side: const BorderSide(color: AppTheme.primaryGreen),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(10),
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

  Widget _buildFlightCard(FlightOption item) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
    child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(item.airlineLogoUrl, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 72, height: 72, color: const Color(0xFFE8F5E9), child: const Icon(Icons.flight, color: AppTheme.primaryGreen)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.airlineName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 4),
        Text(item.route, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Text('${item.priceFormatted} · ${item.duration} · ${item.stops}', style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
      ])),
      _buildFavouriteButton(isFavourite: item.isFavourite, onPressed: () => _toggleFlightSaved(item)),
    ]),
  );

  List<Object> get _allItems {
    final items = <Object>[
      ..._attractions,
      ..._foods,
      ..._hotels,
      ..._flights,
    ];
    // Put group-curated picks first when they match a richer category model.
    for (final suggestion in widget.suggestions.reversed) {
      final index = items.indexWhere(
        (item) =>
            _entryFor(item).title.toLowerCase() ==
            suggestion.title.toLowerCase(),
      );
      if (index > 0) items.insert(0, items.removeAt(index));
    }
    return items;
  }

  Widget _buildAllSuggestionsList() => _buildItemList(_allItems);

  Widget _buildCombinedFavouriteList() => _buildItemList(_allItems.where(_itemFavourite).toList(), emptyMessage: 'No favourite suggestions yet.');

  Widget _buildItemList(List<Object> items, {String emptyMessage = 'No suggestions available.'}) {
    if (items.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(emptyMessage)));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = items[index];
        final card = switch (item) {
          Attraction value => _buildAttractionCard(value),
          FoodOption value => _buildFoodCard(value),
          HotelOption value => _buildHotelCard(value),
          FlightOption value => _buildFlightCard(value),
          _ => const SizedBox.shrink(),
        };
        return _tappableCard(card, item);
      },
    );
  }

  Widget _buildListFromCategory(String category) {
    if (_isLoadingItems) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    return switch (category) {
      'Attractions' => _buildItemList(_attractions),
      'Restaurants' => _buildItemList(_foods),
      'Stays' => _buildItemList(_hotels),
      'Flights' => _buildItemList(_flights),
      'Favourites' => _buildCombinedFavouriteList(),
      _ => _buildAllSuggestionsList(),
    };
  }
  @override
  Widget build(BuildContext context) {
    final categories = <String, IconData>{
      'Favourites': Icons.favorite,
      'Attractions': Icons.location_on,
      'Restaurants': Icons.restaurant,
      'Stays': Icons.bed,
      'Flights': Icons.flight,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: categories.entries.map((category) {
              final cat = category.key;
              final isSelected = _selectedCategoryFilter == cat;
              return Expanded(
                child: Center(
                  child: ChoiceChip(
                    label: Icon(
                      category.value,
                      size: 18,
                      semanticLabel: cat,
                    ),
                    tooltip: cat,
                    selected: isSelected,
                    showCheckmark: false,
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

class _SuggestionEntry {
  final Object item;
  final String title;
  final String imageUrl;
  final String category;
  final List<DetailField> details;

  const _SuggestionEntry({
    required this.item,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.details,
  });
}
