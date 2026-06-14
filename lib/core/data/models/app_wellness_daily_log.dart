import '../local/app_database.dart';

class AppWellnessDailyLog {
  const AppWellnessDailyLog({
    required this.uuidDailyLog,
    required this.uuidProfile,
    required this.fecha,
    required this.energia,
    required this.calma,
    required this.descanso,
    required this.conexion,
    required this.meditacionCompletada,
    required this.minutosBienestar,
    required this.createdAt,
    required this.updatedAt,
    this.mood,
    this.nota,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppWellnessDailyLog.fromLocal(LocalWellnessDailyLog log) {
    return AppWellnessDailyLog(
      uuidDailyLog: log.uuidDailyLog,
      uuidProfile: log.uuidProfile,
      fecha: log.fecha,
      mood: log.mood,
      energia: log.energia,
      calma: log.calma,
      descanso: log.descanso,
      conexion: log.conexion,
      meditacionCompletada: log.meditacionCompletada,
      minutosBienestar: log.minutosBienestar,
      nota: log.nota,
      createdAt: log.createdAt,
      updatedAt: log.updatedAt,
      deletedAt: log.deletedAt,
      syncedAt: log.syncedAt,
    );
  }

  final String uuidDailyLog;
  final String uuidProfile;
  final String fecha;
  final String? mood;
  final int energia;
  final int calma;
  final int descanso;
  final int conexion;
  final bool meditacionCompletada;
  final int minutosBienestar;
  final String? nota;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get hasPendingSync => syncedAt == null || syncedAt!.isBefore(updatedAt);

  bool get hasManualCheckIn {
    return mood != null ||
        energia > 0 ||
        calma > 0 ||
        descanso > 0 ||
        conexion > 0 ||
        nota != null;
  }

  bool get hasActivity {
    return hasManualCheckIn || meditacionCompletada || minutosBienestar > 0;
  }
}
