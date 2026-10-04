import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class UploadFileModal extends StatelessWidget {
  final Function(String fileName) onFileSelected;

  const UploadFileModal({super.key, required this.onFileSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload Document or File',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.deepPurple),
            ),
            title: const Text('Kyoto_Itinerary_V1.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('PDF Document · 1.2 MB'),
            onTap: () {
              Navigator.pop(context);
              onFileSelected('📄 Kyoto_Itinerary_V1.pdf');
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_rounded, color: Colors.teal),
            ),
            title: const Text('Flight_Confirmation.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('PDF Document · 450 KB'),
            onTap: () {
              Navigator.pop(context);
              onFileSelected('📄 Flight_Confirmation.pdf');
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}