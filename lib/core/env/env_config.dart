import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Gracefully fall back to defaults if .env is missing or unreadable
    }
  }

  static String get supabaseUrl {
    try {
      return dotenv.env['SUPABASE_URL'] ??
          'https://dummy-efooty-project.supabase.co';
    } catch (_) {
      return 'https://dummy-efooty-project.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    try {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? 'dummy-anon-key';
    } catch (_) {
      return 'dummy-anon-key';
    }
  }

  static String get geminiApiKey {
    try {
      return dotenv.env['GEMINI_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static bool get isSupabaseConfigured {
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    return url.isNotEmpty &&
        !url.contains('dummy-') &&
        !url.contains('your-project') &&
        key.isNotEmpty &&
        !key.contains('dummy-') &&
        !key.contains('your-anon-key');
  }

  static bool get isGeminiConfigured {
    final key = geminiApiKey;
    return key.isNotEmpty &&
        !key.contains('dummy-') &&
        !key.contains('your-gemini');
  }
}
