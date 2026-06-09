abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const contentItems = String.fromEnvironment(
    'SUPABASE_CONTENT_ITEMS_TABLE',
    defaultValue: 'content_items',
  );
}
