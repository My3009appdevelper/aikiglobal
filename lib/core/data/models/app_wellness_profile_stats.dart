import '../local/app_database.dart';

class AppWellnessProfileStats {
  const AppWellnessProfileStats({
    required this.uuidProfile,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalActiveDays,
    required this.updatedAt,
    this.lastActivityDate,
    this.syncedAt,
  });

  factory AppWellnessProfileStats.fromLocal(LocalWellnessProfileStats stats) {
    return AppWellnessProfileStats(
      uuidProfile: stats.uuidProfile,
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      lastActivityDate: stats.lastActivityDate,
      totalActiveDays: stats.totalActiveDays,
      updatedAt: stats.updatedAt,
      syncedAt: stats.syncedAt,
    );
  }

  final String uuidProfile;
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final int totalActiveDays;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  bool get hasPendingSync => syncedAt == null || syncedAt!.isBefore(updatedAt);
}
