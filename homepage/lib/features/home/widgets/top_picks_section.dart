import 'package:flutter/material.dart';
import '../../../models/recommendation.dart';
import '../../../services/recommendation_service.dart';
import 'recommendation_card.dart';

/// Top Picks Section
class TopPicksSection extends StatefulWidget {
  const TopPicksSection({super.key});

  @override
  State<TopPicksSection> createState() => _TopPicksSectionState();
}

class _TopPicksSectionState extends State<TopPicksSection> {
  final RecommendationService _recommendationService = RecommendationService();
  late Future<List<Recommendation>> _topPicksFuture;

  @override
  void initState() {
    super.initState();
    _topPicksFuture = _recommendationService.getTopPicks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recommendation>>(
      future: _topPicksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final topPicks = snapshot.data!;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topPicks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final pick = topPicks[index];
            return RecommendationCard.fromModel(recommendation: pick);
          },
        );
      },
    );
  }
}