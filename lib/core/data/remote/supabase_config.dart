import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool _initialized = false;

  static bool get hasEnvironment => url.isNotEmpty && anonKey.isNotEmpty;
  static bool get isInitialized => _initialized;

  static SupabaseClient? get clientOrNull {
    if (!_initialized) {
      return null;
    }

    return Supabase.instance.client;
  }

  static Future<void> initializeIfConfigured() async {
    if (!hasEnvironment || isInitialized) {
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }
}
