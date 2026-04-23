import 'package:flutter/material.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import 'package:e_ticketing_helpdesk/core/theme/theme_notifier.dart';
import 'package:e_ticketing_helpdesk/screens/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'E-Ticketing Helpdesk',
          debugShowCheckedModeBanner: false, // menghilangkan banner debug
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode, // mrespons dari theme_notifier.dart
          home: const SplashScreen(),
        );
      },
    );
  }
}