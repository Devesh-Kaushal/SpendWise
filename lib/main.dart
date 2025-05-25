
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ).copyWith(
          primary: Color(0xFF6C5CE7),
          secondary: Color(0xFFA29BFE),
          tertiary: Color(0xFF00B894),
          surface: Color(0xFFFDFDFD),
          background: Color(0xFFF8F9FA),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ).copyWith(
          primary: Color(0xFF7B68EE),
          secondary: Color(0xFFB19CD9),
          tertiary: Color(0xFF00CCA3),
          surface: Color(0xFF1A1A1A),
          background: Color(0xFF0D1117),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
