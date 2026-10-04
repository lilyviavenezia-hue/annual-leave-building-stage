import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'scanned_receipt_screen.dart';

class ReceiptScannerScreen extends StatelessWidget {
  final String groupId;

  const ReceiptScannerScreen({super.key, required this.groupId});

  void _proceedToReceipt(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScannedReceiptScreen(groupId: groupId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Viewfinder Simulation
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryGreen, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 80,
                      color: Colors.white38,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Align receipt inside the frame',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Bar
            Positioned(
              top: 16,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Bottom Actions (Shutter + Gallery Icon in Bottom Left)
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bottom Left: Select Photos from Gallery Button
                  GestureDetector(
                    onTap: () => _proceedToReceipt(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white38),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.photo_library, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center: Shutter Button
                  GestureDetector(
                    onTap: () => _proceedToReceipt(context),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: AppTheme.primaryGreen,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                    ),
                  ),

                  const SizedBox(width: 80), // Spacer balancing left button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}