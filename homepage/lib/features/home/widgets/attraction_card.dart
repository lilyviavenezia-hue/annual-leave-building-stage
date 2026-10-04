import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/attraction.dart';

class AttractionCard extends StatelessWidget {
  final String title;
  final String location;
  final String imageUrl;
  final String price;
  final List<String> tags;
  final double rating;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const AttractionCard({
    super.key,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.tags,
    required this.rating,
    required this.isFavorite,
    required this.onFavorite,
  });

  /// Factory constructor to easily create card from an Attraction model
  factory AttractionCard.fromModel({Key? key, required Attraction attraction}) {
    return AttractionCard(
      key: key,
      title: attraction.title,
      location: attraction.location,
      imageUrl: attraction.imageUrl,
      price: attraction.price,
      tags: attraction.tags,
      rating: attraction.rating,
      isFavorite: false,
      onFavorite: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E2DA)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              imageUrl,
              height: 116,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 116,
                color: Colors.blueGrey.shade700,
                child: const Icon(
                  Icons.landscape_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: AppTheme.primaryGreen,
                        size: 14,
                      ),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onFavorite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        isFavorite
                            ? 'Added to Favourites'
                            : 'Add to Favourites',
                        style: const TextStyle(fontSize: 11),
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
