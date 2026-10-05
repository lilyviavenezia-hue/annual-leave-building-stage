import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../models/attraction.dart';
import '../../../models/food_option.dart';
import '../../../models/group_trip_summary.dart';
import '../../../models/hotel.dart';
import '../../../services/food_service.dart';
import '../../../services/hotel_service.dart';
import '../../../services/recommendation_service.dart';

class SummaryOverviewTab extends StatefulWidget {
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

  @override
  State<SummaryOverviewTab> createState() => _SummaryOverviewTabState();
}

class _SummaryOverviewTabState extends State<SummaryOverviewTab> {
  final RecommendationService _recommendationService = RecommendationService();
  final FoodService _foodService = FoodService();
  final HotelService _hotelService = HotelService();

  late Future<List<Attraction>> _attractionsFuture;
  late Future<List<FoodOption>> _foodFuture;
  late Future<List<HotelOption>> _hotelsFuture;

  final Set<String> _favoriteAttractionIds = {};
  final Set<String> _favoriteFoodIds = {};
  final Set<String> _favoriteHotelIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavouriteData();
  }

  void _loadFavouriteData() {
    final destination = widget.tripSummary.destination.split(',').first.trim();
    _attractionsFuture = _recommendationService.getRecommendedAttractions();
    _foodFuture = _foodService.getRecommendedEats(destination.isNotEmpty ? destination : 'Kyoto');
    _hotelsFuture = _hotelService.searchHotels(destination.isNotEmpty ? destination : 'Kyoto');
  }

  IconData _getCategoryIcon(String key) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('budget')) return Icons.help_outline;
    if (lowerKey.contains('accommodation')) return Icons.hotel_outlined;
    if (lowerKey.contains('destination')) return Icons.location_on_outlined;
    if (lowerKey.contains('date')) return Icons.calendar_today_outlined;
    if (lowerKey.contains('transport')) return Icons.directions_bus_outlined;
    if (lowerKey.contains('friend') || lowerKey.contains('traveller') || lowerKey.contains('traveler')) {
      return Icons.people_outline;
    }
    return Icons.check_circle_outline;
  }

  void _toggleFavorite(String category, String id) {
    setState(() {
      switch (category) {
        case 'Attractions':
          _favoriteAttractionIds.contains(id)
              ? _favoriteAttractionIds.remove(id)
              : _favoriteAttractionIds.add(id);
        case 'Restaurants':
          _favoriteFoodIds.contains(id)
              ? _favoriteFoodIds.remove(id)
              : _favoriteFoodIds.add(id);
        case 'Stays':
          _favoriteHotelIds.contains(id)
              ? _favoriteHotelIds.remove(id)
              : _favoriteHotelIds.add(id);
      }
    });
  }

  String _formatRangeLabel(DateTimeRange range) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final start = range.start;
    final end = range.end;
    final startText = '${monthNames[start.month - 1]} ${start.day}';
    final endText = '${monthNames[end.month - 1]} ${end.day}';
    return '$startText - $endText, ${end.year}';
  }

  Future<void> _showDateEditSheet(BuildContext context, String key, String currentValue) async {
    final initialRange = _parseDateRange(currentValue);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5, 12, 31),
      initialDateRange: initialRange,
    );

    if (picked == null || !mounted) return;

    final formatted = _formatRangeLabel(picked);
    widget.onConfirmedDetailUpdated(key, formatted);
  }

  DateTimeRange? _parseDateRange(String value) {
    final sanitized = value.replaceAll('–', '-').replaceAll('—', '-');
    final dashIndex = sanitized.indexOf('-');
    if (dashIndex == -1) {
      final parsed = DateTime.tryParse(sanitized);
      if (parsed == null) return null;
      return DateTimeRange(start: parsed, end: parsed.add(const Duration(days: 1)));
    }

    final left = sanitized.substring(0, dashIndex).trim();
    final right = sanitized.substring(dashIndex + 1).trim();
    final start = DateTime.tryParse(left);
    final end = DateTime.tryParse(right);
    if (start == null || end == null) return null;
    return DateTimeRange(start: start, end: end);
  }

  void _showEditDetailSheet(BuildContext context, String key, String currentValue) {
    if (key.toLowerCase().contains('date')) {
      _showDateEditSheet(context, key, currentValue);
      return;
    }

    final TextEditingController controller = TextEditingController(text: currentValue);

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
                    borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
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
                      widget.onConfirmedDetailUpdated(key, newValue);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Planning status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.tripSummary.pendingDecisions.length} TO DECIDE',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEA7D00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Needs your group to decide • tap a card to resolve it',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          if ((widget.tripSummary.confirmedDetails['Budget'] ?? widget.tripSummary.budget).isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Budget range',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.tripSummary.confirmedDetails['Budget'] ?? widget.tripSummary.budget,
                          style: const TextStyle(
                            fontSize: 13,
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
            const SizedBox(height: 16),
          ],
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            children: [
              ...widget.tripSummary.pendingDecisions
                  .where((decision) => decision != 'Budget')
                  .map((decision) {
                return GestureDetector(
                  onTap: widget.onSelectPendingDecision,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            size: 18,
                            color: Color(0xFFE0A402),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          decision,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Needs decision',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              ...widget.tripSummary.confirmedDetails.entries
                  .where((entry) => entry.key != 'Budget')
                  .map((entry) {
                return GestureDetector(
                  onTap: () => _showEditDetailSheet(context, entry.key, entry.value),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFA5D6A7)),
                    ),
                    child: Stack(
                      children: [
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
                                size: 20,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.key,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.value,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
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
          const Text(
            'Favourites',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildFavouriteSection('Attractions', _attractionsFuture, _favoriteAttractionIds, _buildAttractionFavouriteCard),
          const SizedBox(height: 12),
          _buildFavouriteSection('Restaurants', _foodFuture, _favoriteFoodIds, _buildFoodFavouriteCard),
          const SizedBox(height: 12),
          _buildFavouriteSection('Stays', _hotelsFuture, _favoriteHotelIds, _buildHotelFavouriteCard),
          const SizedBox(height: 22),
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildEditablePreferences(widget.tripSummary.preferenceTags),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFavouriteSection<T>(
    String title,
    Future<List<T>> future,
    Set<String> favourites,
    Widget Function(T item, bool isFavorite, VoidCallback onToggle) cardBuilder,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                '${favourites.length} saved',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<T>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No favourites yet', style: TextStyle(color: AppTheme.textMuted));
              }

              final items = snapshot.data!;
              return Column(
                children: [
                  for (final item in items.take(2))
                    cardBuilder(
                      item,
                      _isFavoriteForCategory(title, item),
                      () => _toggleFavorite(title, _itemIdForCategory(title, item)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isFavoriteForCategory(String category, dynamic item) {
    final id = _itemIdForCategory(category, item);
    switch (category) {
      case 'Attractions':
        return _favoriteAttractionIds.contains(id);
      case 'Restaurants':
        return _favoriteFoodIds.contains(id);
      case 'Stays':
        return _favoriteHotelIds.contains(id);
      default:
        return false;
    }
  }

  String _itemIdForCategory(String category, dynamic item) {
    switch (category) {
      case 'Attractions':
        return (item as Attraction).id;
      case 'Restaurants':
        return (item as FoodOption).id;
      case 'Stays':
        return (item as HotelOption).id;
      default:
        return '';
    }
  }

  Widget _buildAttractionFavouriteCard(Attraction item, bool isFavorite, VoidCallback onToggle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: Colors.grey[300]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 3),
                Text(item.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(item.price, style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppTheme.primaryGreen : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodFavouriteCard(FoodOption item, bool isFavorite, VoidCallback onToggle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: Colors.grey[300], child: const Icon(Icons.restaurant)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 3),
                Text('${item.cuisineType} • ${item.priceTier}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFFBBC04)),
                    const SizedBox(width: 2),
                    Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppTheme.primaryGreen : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelFavouriteCard(HotelOption item, bool isFavorite, VoidCallback onToggle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hotel_outlined, color: AppTheme.primaryGreen, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 3),
                Text(item.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFFBBC04)),
                    const SizedBox(width: 2),
                    Text(item.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(item.pricePerNightFormatted, style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppTheme.primaryGreen : AppTheme.textMuted,
            ),
          ),
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
              widget.onTagsUpdated();
            },
            deleteIcon: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
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
            widget.onTagsUpdated();
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