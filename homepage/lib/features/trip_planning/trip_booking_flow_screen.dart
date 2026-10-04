import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/attraction.dart';
import '../../models/flight.dart';
import '../../models/food_option.dart';
import '../../models/hotel.dart';
import '../../models/trip.dart';
import '../../models/trip_booking.dart';
import '../../services/trip_booking_service.dart';
import '../../services/trip_service.dart';

class TripBookingFlowScreen extends StatefulWidget {
  const TripBookingFlowScreen({super.key, required this.trip});

  final Trip trip;

  @override
  State<TripBookingFlowScreen> createState() => _TripBookingFlowScreenState();
}

class _TripBookingFlowScreenState extends State<TripBookingFlowScreen> {
  final TripBookingService _bookingService = TripBookingService();
  final TextEditingController _searchController = TextEditingController();
  late final Future<TripBookingOptions> _optionsFuture;
  int _selectedCategory = 0;
  String _searchQuery = '';
  String? _flightId;
  String? _hotelId;
  final Set<String> _attractionIds = {};
  final Set<String> _foodIds = {};

  static const _categories = ['Flights', 'Hotels', 'Attractions', 'Food'];

  @override
  void initState() {
    super.initState();
    _optionsFuture = _bookingService.getOptions(widget.trip);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TripBookingSelection _selection() => TripBookingSelection(
    flightId: _flightId,
    hotelId: _hotelId,
    attractionIds: _attractionIds.toList(),
    foodIds: _foodIds.toList(),
  );

  String get _pageTitle => switch (_selectedCategory) {
    0 => 'Compare Flights',
    1 => 'Compare Hotels',
    2 => '${widget.trip.destination.split(',').first} Attractions',
    _ => 'Recommended Eats',
  };

  void _continueToBudget(TripBookingOptions options) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripBookingBudgetScreen(
          trip: widget.trip,
          options: options,
          selection: _selection(),
          bookingService: _bookingService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<TripBookingOptions>(
          future: _optionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to load trip options: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final options = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'annual leave',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Back',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _pageTitle,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.trip.destination} · ${widget.trip.dateRange}',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final selected = _selectedCategory == index;
                            return ChoiceChip(
                              label: Text(_categories[index]),
                              selected: selected,
                              onSelected: (_) => setState(() {
                                _selectedCategory = index;
                                _searchController.clear();
                                _searchQuery = '';
                              }),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              selectedColor: AppTheme.primaryGreen,
                              backgroundColor: const Color(0xFFF2F2F6),
                              showCheckmark: false,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value.trim()),
                        decoration: InputDecoration(
                          hintText:
                              'Search ${widget.trip.destination.split(',').first}',
                          prefixIcon: const Icon(Icons.search, size: 19),
                          filled: true,
                          fillColor: const Color(0xFFF2F2F6),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                      if (_selectedCategory == 0) ...[
                        const SizedBox(height: 10),
                        _FlightRouteSummary(trip: widget.trip),
                      ],
                    ],
                  ),
                ),
                Expanded(child: _buildResults(options)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => _continueToBudget(options),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Review estimated budget'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResults(TripBookingOptions options) {
    final children = switch (_selectedCategory) {
      0 => _flightCards(options.flights),
      1 => _hotelCards(options.hotels),
      2 => _attractionCards(options.attractions),
      _ => _foodCards(options.food),
    };
    if (children.isEmpty) {
      return const Center(child: Text('No options match your search.'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      children: children,
    );
  }

  List<Widget> _flightCards(List<FlightOption> flights) => [
    for (final flight in flights.where((item) => _matches(item.airlineName)))
      _OptionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flight_rounded,
                  color: AppTheme.primaryGreen,
                  size: 19,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    flight.airlineName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  flight.priceFormatted,
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    flight.departureTime,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  flight.duration,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
                Expanded(
                  child: Text(
                    flight.arrivalTime,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '${flight.flightType} · ${flight.terminal}',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
            const SizedBox(height: 10),
            _selectButton(
              selected: _flightId == flight.id,
              label: 'Select Flight',
              onPressed: () => setState(
                () => _flightId = _flightId == flight.id ? null : flight.id,
              ),
            ),
          ],
        ),
      ),
  ];

  List<Widget> _hotelCards(List<HotelOption> hotels) => [
    for (final hotel in hotels.where((item) => _matches(item.name)))
      _OptionCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NetworkImage(url: hotel.imageUrl, height: 130),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        hotel.pricePerNightFormatted,
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hotel.location} · ★ ${hotel.rating}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 5,
                    children: [
                      for (final amenity in hotel.amenities)
                        _Tag(label: amenity),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _selectButton(
                    selected: _hotelId == hotel.id,
                    label: 'Select Hotel',
                    onPressed: () => setState(
                      () => _hotelId = _hotelId == hotel.id ? null : hotel.id,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
  ];

  List<Widget> _attractionCards(List<Attraction> attractions) => [
    for (final attraction in attractions.where((item) => _matches(item.title)))
      _OptionCard(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _NetworkImage(
                url: attraction.imageUrl,
                width: 62,
                height: 62,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final shouldAdd = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => AttractionBookingDetailsScreen(
                        attraction: attraction,
                      ),
                    ),
                  );
                  if (shouldAdd == true && mounted) {
                    setState(() => _attractionIds.add(attraction.id));
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attraction.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      attraction.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      '★ ${attraction.rating} · ${attraction.price}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _smallSelectButton(
              selected: _attractionIds.contains(attraction.id),
              onPressed: () => setState(() {
                if (!_attractionIds.add(attraction.id)) {
                  _attractionIds.remove(attraction.id);
                }
              }),
            ),
          ],
        ),
      ),
  ];

  List<Widget> _foodCards(List<FoodOption> food) => [
    for (final option in food.where((item) => _matches(item.name)))
      _OptionCard(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(15),
              ),
              child: _NetworkImage(
                url: option.imageUrl,
                width: 82,
                height: 104,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '★ ${option.rating} (${option.reviewCount} reviews)',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _smallSelectButton(
                selected: _foodIds.contains(option.id),
                onPressed: () => setState(() {
                  if (!_foodIds.add(option.id)) _foodIds.remove(option.id);
                }),
              ),
            ),
          ],
        ),
      ),
  ];

  bool _matches(String value) =>
      _searchQuery.isEmpty ||
      value.toLowerCase().contains(_searchQuery.toLowerCase());

  Widget _selectButton({
    required bool selected,
    required String label,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: double.infinity,
    height: 34,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppTheme.primaryGreen : Colors.white,
        foregroundColor: selected ? Colors.white : AppTheme.textDark,
        side: BorderSide(
          color: selected ? AppTheme.primaryGreen : const Color(0xFFE7E7EB),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(selected ? 'Selected' : label),
    ),
  );

  Widget _smallSelectButton({
    required bool selected,
    required VoidCallback onPressed,
  }) => SizedBox(
    width: 36,
    height: 30,
    child: IconButton.filled(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? const Color(0xFFE5F7EB)
            : AppTheme.primaryGreen,
        foregroundColor: selected ? AppTheme.primaryGreen : Colors.white,
      ),
      icon: Icon(selected ? Icons.check : Icons.add, size: 16),
    ),
  );
}

class AttractionBookingDetailsScreen extends StatelessWidget {
  const AttractionBookingDetailsScreen({super.key, required this.attraction});

  final Attraction attraction;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _NetworkImage(url: attraction.imageUrl, height: 220),
                ),
                const SizedBox(height: 14),
                Text(
                  attraction.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '★ ${attraction.rating} · ${attraction.location}',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${attraction.title} is one of the well-known highlights around ${attraction.location}. '
                  'Add it to your trip plan, then review the estimated cost before confirming.',
                  style: const TextStyle(
                    height: 1.5,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'From ${attraction.price} per person',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add to trip'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class TripBookingBudgetScreen extends StatefulWidget {
  const TripBookingBudgetScreen({
    super.key,
    required this.trip,
    required this.options,
    required this.selection,
    required this.bookingService,
  });

  final Trip trip;
  final TripBookingOptions options;
  final TripBookingSelection selection;
  final TripBookingService bookingService;

  @override
  State<TripBookingBudgetScreen> createState() =>
      _TripBookingBudgetScreenState();
}

class _TripBookingBudgetScreenState extends State<TripBookingBudgetScreen> {
  bool _saving = false;

  Future<void> _confirm() async {
    setState(() => _saving = true);
    try {
      final quote = widget.bookingService.estimate(
        widget.trip,
        widget.options,
        widget.selection,
      );
      double amountFor(String category) =>
          quote.lines.firstWhere((line) => line.category == category).amount;
      final confirmedTrip = widget.trip.copyWith(
        estimatedBudget: quote.total,
        budgetBreakdown: {
          'Transport': amountFor('Flights') + amountFor('Transport'),
          'Accommodation': amountFor('Accommodation'),
          'Food': amountFor('Food'),
          'Activities': amountFor('Activities'),
          'Other expenses': 0,
        },
      );
      await TripService().confirmTrip(confirmedTrip);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(
          builder: (_) => TripConfirmedScreen(trip: confirmedTrip),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to confirm trip: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.bookingService.estimate(
      widget.trip,
      widget.options,
      widget.selection,
    );
    final onBudget = quote.remaining >= 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Budget'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
        children: [
          Text(
            'Budget summary',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F6),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Estimated total',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      _money(quote.total),
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'For ${quote.travellerCount} travellers · ${widget.trip.duration}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: quote.plannedBudget <= 0
                        ? 0
                        : (quote.total / quote.plannedBudget).clamp(0, 1),
                    minHeight: 7,
                    color: onBudget ? AppTheme.primaryGreen : Colors.red,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  onBudget
                      ? '${_money(quote.remaining)} estimated budget remaining'
                      : '${_money(quote.remaining.abs())} over planned budget',
                  style: TextStyle(
                    color: onBudget ? AppTheme.primaryGreen : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Line items',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final line in quote.lines)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F6),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          line.isSelected ? 'Selected option' : 'Estimated',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _money(line.amount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          const Text(
            'Prices are estimates based on your selected options and trip details. Bookings are not purchased in this demo.',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _saving ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Confirm trip'),
            ),
          ),
        ],
      ),
    );
  }
}

class TripConfirmedScreen extends StatelessWidget {
  const TripConfirmedScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your trip is confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Everything is ready for your journey to ${trip.destination.split(',').first}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => context.go('/trips'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View my trips'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FlightRouteSummary extends StatelessWidget {
  const _FlightRouteSummary({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F8FA),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '${trip.originCity} (KUL)',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        const Icon(Icons.arrow_forward, color: AppTheme.primaryGreen, size: 15),
        Expanded(
          child: Text(
            trip.destination.split(',').first == 'Kyoto'
                ? 'Osaka (KIX)'
                : trip.destination.split(',').first,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.calendar_month_outlined,
          color: AppTheme.primaryGreen,
          size: 17,
        ),
      ],
    ),
  );
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE8E8EC)),
      borderRadius: BorderRadius.circular(15),
    ),
    child: child,
  );
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url, this.width, required this.height});

  final String url;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFFE8EBE8),
        child: Icon(Icons.landscape_outlined, color: AppTheme.textMuted),
      ),
    ),
  );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F6),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
    ),
  );
}

String _money(double amount) => 'RM ${amount.round()}';
