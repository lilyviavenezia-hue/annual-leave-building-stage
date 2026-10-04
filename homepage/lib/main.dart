import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing and navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnnualLeaveApp());
}

class AnnualLeaveApp extends StatelessWidget {
  const AnnualLeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Annual Leave',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}