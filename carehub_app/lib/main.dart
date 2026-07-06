import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/auth/welcome_screen.dart';

void main() => runApp(const CareHubApp());

class CareHubApp extends StatelessWidget {
  const CareHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTheme.brandName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const WelcomeScreen(),
    );
  }
}