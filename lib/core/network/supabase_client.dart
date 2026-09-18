import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env_config.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> init() async {
    if (EnvConfig.isSupabaseConfigured) {
      try {
        await Supabase.initialize(
          url: EnvConfig.supabaseUrl,
          publishableKey: EnvConfig.supabaseAnonKey,
        );
        _isInitialized = true;
      } catch (e) {
        _isInitialized = false;
      }
    } else {
      _isInitialized = false;
    }
  }

  static SupabaseClient? get client {
    if (_isInitialized) {
      return Supabase.instance.client;
    }
    return null;
  }
}
