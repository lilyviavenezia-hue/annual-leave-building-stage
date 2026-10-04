import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../models/group_trip_summary.dart';

class SuggestionDetailModal extends StatelessWidget {
  final GroupSuggestion suggestion;

  const SuggestionDetailModal({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(suggestion.title),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(suggestion.imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(suggestion.category, style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                      Text('${suggestion.matchPercentage}% Match', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(suggestion.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(suggestion.location, style: const TextStyle(color: AppTheme.textMuted, fontSize: 15)),
                  const SizedBox(height: 20),
                  const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Top-rated destination highly matched with your group\'s preferred pace and interests.',
                    style: TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.5),
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