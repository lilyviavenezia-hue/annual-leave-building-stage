import 'package:flutter/material.dart';

import '../../../models/attraction.dart';
import '../../../services/favorite_service.dart';
import '../../../services/recommendation_service.dart';
import 'attraction_card.dart';

/// Recommended Attractions Section Component
class RecommendedAttractionsSection extends StatefulWidget {
  const RecommendedAttractionsSection({super.key});

  @override
  State<RecommendedAttractionsSection> createState() =>
      _RecommendedAttractionsSectionState();
}

class _RecommendedAttractionsSectionState
    extends State<RecommendedAttractionsSection> {
  final RecommendationService _recommendationService = RecommendationService();
  final FavoriteService _favoriteService = FavoriteService();
  Set<String> _favoriteIds = {};
  late Future<List<Attraction>> _attractionsFuture;

  @override
  void initState() {
    super.initState();
    _attractionsFuture = _recommendationService.getRecommendedAttractions();
    _loadFavorites();
    FavoriteService.favoritesRevision.addListener(_loadFavorites);
  }

  @override
  void dispose() {
    FavoriteService.favoritesRevision.removeListener(_loadFavorites);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoriteService.getFavoriteIds();
    if (!mounted) return;
    setState(() => _favoriteIds = ids);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Attraction>>(
      future: _attractionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final attractions = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: attractions.length,
          itemBuilder: (context, index) {
            final attraction = attractions[index];
            return AttractionCard(
              title: attraction.title,
              location: attraction.location,
              imageUrl: attraction.imageUrl,
              price: attraction.price,
              tags: attraction.tags,
              rating: attraction.rating,
              isFavorite: _favoriteIds.contains(attraction.id),
              onFavorite: () => _favoriteService.toggleFavorite(attraction),
            );
          },
        );
      },
    );
  }
}