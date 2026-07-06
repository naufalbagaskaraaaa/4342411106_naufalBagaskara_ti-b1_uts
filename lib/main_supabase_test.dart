import 'package:flutter/material.dart';
import 'package:e_ticketing_helpdesk/core/config/app_config.dart';
import 'package:e_ticketing_helpdesk/core/constants/supabase_constants.dart';
import 'package:e_ticketing_helpdesk/core/theme/app_theme.dart';
import 'package:e_ticketing_helpdesk/core/theme/theme_notifier.dart';
import 'package:e_ticketing_helpdesk/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppConfig.initialize();

    final response = await AppConfig.supabase
        .from(SupabaseConstants.usersTable)
        .select('id')
        .limit(1);

    debugPrint('✓ Supabase initialized successfully');
    debugPrint('✓ Connection test result: ${response.length} row(s) fetched');
  } catch (e) {
    debugPrint('✗ Supabase initialization failed: $e');
  }

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
          title: 'E-Ticketing Helpdesk Supabase Test',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
