import 'package:flutter/material.dart';
import 'package:hype_grid/utils/app_theme.dart';
import 'package:hype_grid/pages/splash/splash_screen.dart';

void main() {
  runApp(const HypeGridApp());
}

class HypeGridApp extends StatelessWidget {
  const HypeGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HypeGrid',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
