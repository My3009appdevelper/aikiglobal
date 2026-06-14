abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const contentItems = String.fromEnvironment(
    'SUPABASE_CONTENT_ITEMS_TABLE',
    defaultValue: 'content_items',
  );
  static const userContentStates = 'user_content_states';
  static const wellnessDailyLogs = 'wellness_daily_logs';
  static const wellnessProfileStats = 'wellness_profile_stats';
}
