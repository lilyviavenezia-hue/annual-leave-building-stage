import 'package:flutter/material.dart';
import '../../../models/attraction.dart';
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
  late Future<List<Attraction>> _attractionsFuture;

  @override
  void initState() {
    super.initState();
    _attractionsFuture = _recommendationService.getRecommendedAttractions();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: FutureBuilder<List<Attraction>>(
        future: _attractionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final attractions = snapshot.data!;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attractions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final attraction = attractions[index];
              return AttractionCard.fromModel(attraction: attraction);
            },
          );
        },
      ),
    );
  }
}