abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const companyInfo = 'company_info';
  static const contentItems = String.fromEnvironment(
    'SUPABASE_CONTENT_ITEMS_TABLE',
    defaultValue: 'content_items',
  );
  static const contentMedia = 'content_media';
  static const notificationDevices = 'notification_devices';
  static const notificationEvents = 'notification_events';
  static const notificationDispatches = 'notification_dispatches';
  static const notificationsInbox = 'notifications_inbox';
  static const userContentStates = 'user_content_states';
  static const wellnessDailyLogs = 'wellness_daily_logs';
  static const wellnessProfileStats = 'wellness_profile_stats';
  static const subscriptionProducts = 'subscription_products';
  static const userSubscriptions = 'user_subscriptions';
  static const subscriptionTransactions = 'subscription_transactions';
}
