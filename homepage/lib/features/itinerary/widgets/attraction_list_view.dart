import 'package:flutter/material.dart';

import '../../../../models/attraction.dart';
import '../../../../models/itinerary.dart';
import 'attraction_card.dart';

class AttractionListView extends StatefulWidget {
  final List<Attraction> attractions;
  final String destinationCity;
  final ValueChanged<ItineraryDetailItem> onAddToTimeline;

  const AttractionListView({
    super.key,
    required this.attractions,
    required this.onAddToTimeline,
    this.destinationCity = 'Kyoto',
  });

  @override
  State<AttractionListView> createState() => _AttractionListViewState();
}

class _AttractionListViewState extends State<AttractionListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter list based on search query
    final filteredList = widget.attractions.where((item) {
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Pill-shaped Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search ${widget.destinationCity}',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Filtered Attractions Cards List
        Expanded(
          child: filteredList.isEmpty
              ? Center(
                  child: Text(
                    'No attractions found.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return AttractionCard(
                      attraction: filteredList[index],
                      onAddToTimeline: widget.onAddToTimeline,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
