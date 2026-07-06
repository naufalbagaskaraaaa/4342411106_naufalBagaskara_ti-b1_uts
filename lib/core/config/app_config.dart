import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Application configuration and environment setup
class AppConfig {
  static const String _envFileName = '.env';
  static bool _isInitialized = false;
  static bool _debugMode = true; // Default to true for development

  /// Initialize app configuration
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to load environment variables (may fail on web)
      try {
        await dotenv.load(fileName: _envFileName);
      } catch (e) {
        // Env loading failed (common on web), continue with defaults
        debugPrint('Env loading skipped: $e');
      }

      // Get required environment variables with fallback
      final supabaseUrl = _getEnv('SUPABASE_URL');
      final supabaseKey = _getEnv('SUPABASE_ANON_KEY');

      // Validate required variables
      if (supabaseUrl.isEmpty || supabaseUrl == 'your_supabase_project_url') {
        throw Exception(
          'SUPABASE_URL not configured. Please set it in .env file.',
        );
      }
      if (supabaseKey.isEmpty || supabaseKey == 'your_supabase_anon_key') {
        throw Exception(
          'SUPABASE_ANON_KEY not configured. Please set it in .env file.',
        );
      }

      // Determine debug mode from env or default to true
      final appEnv = _getEnv('APP_ENV', fallback: 'development');
      _debugMode = appEnv == 'development';

      // Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseKey,
        debug: _debugMode,
      );

      _isInitialized = true;
      if (_debugMode) {
        debugPrint('✓ App configuration initialized successfully');
        debugPrint('✓ Supabase connected');
        debugPrint('✓ Environment: $appEnv');
      }
    } catch (e) {
      if (_debugMode) {
        debugPrint('✗ Error initializing app configuration: $e');
      }
      rethrow;
    }
  }

  /// Get environment variable with fallback
  static String _getEnv(String key, {String fallback = ''}) {
    // Try to get from loaded env first
    final value = dotenv.env[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return fallback;
  }

  /// Get Supabase client instance
  static SupabaseClient get supabase => Supabase.instance.client;

  /// Get app name
  static String getAppName() => _getEnv('APP_NAME', fallback: 'E-Ticketing Helpdesk');

  /// Get app version
  static String getAppVersion() => _getEnv('APP_VERSION', fallback: '1.0.0');

  /// Get current environment
  static String getAppEnv() => _getEnv('APP_ENV', fallback: 'development');

  /// Check if running in development mode
  static bool isDevelopment() => _debugMode;

  /// Check if running in production mode
  static bool isProduction() => !_debugMode;
}
