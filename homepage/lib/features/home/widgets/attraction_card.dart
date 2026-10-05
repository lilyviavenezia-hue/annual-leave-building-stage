import 'package:flutter/material.dart';
import '../../../models/attraction.dart';

class AttractionCard extends StatelessWidget {
  final String title;
  final String location;
  final String imageUrl;

  const AttractionCard({
    super.key,
    required this.title,
    required this.location,
    required this.imageUrl,
  });

  /// Factory constructor to easily create card from an Attraction model
  factory AttractionCard.fromModel({
    Key? key,
    required Attraction attraction,
  }) {
    return AttractionCard(
      key: key,
      title: attraction.title,
      location: attraction.location,
      imageUrl: attraction.imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              location,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}