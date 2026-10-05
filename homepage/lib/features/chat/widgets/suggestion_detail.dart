import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
class DetailField {
  final String label;
  final String value;

  const DetailField(this.label, this.value);
}

/// Shared detail layout for attraction, restaurant, stay, and flight models.
class SuggestionDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String category;
  final List<DetailField> details;
  final bool isFavourite;
  final VoidCallback onToggleFavourite;

  const SuggestionDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.details,
    required this.isFavourite,
    required this.onToggleFavourite,
  });

  @override
  State<SuggestionDetailPage> createState() => _SuggestionDetailPageState();
}

class _SuggestionDetailPageState extends State<SuggestionDetailPage> {
  late bool _isFavourite = widget.isFavourite;

  @override
  Widget build(BuildContext context) {
    final visibleDetails = widget.details
        .where((detail) => detail.value.trim().isNotEmpty)
        .toList(growable: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.imageUrl,
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 320,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, size: 48, color: AppTheme.textMuted),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.category,
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _isFavourite = !_isFavourite);
                          widget.onToggleFavourite();
                        },
                        tooltip: _isFavourite ? 'Remove favourite' : 'Add favourite',
                        icon: Icon(
                          _isFavourite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavourite ? Colors.red : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 20),
                  for (final detail in visibleDetails) ...[
                    Text(detail.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    Text(detail.value, style: const TextStyle(fontSize: 15, color: AppTheme.textMuted, height: 1.45)),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
