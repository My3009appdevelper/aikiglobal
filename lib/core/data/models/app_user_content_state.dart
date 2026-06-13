import '../local/app_database.dart';

class AppUserContentState {
  const AppUserContentState({
    required this.uuidUserContentState,
    required this.uuidProfile,
    required this.uuidContentItem,
    required this.favorito,
    required this.progresoPorcentaje,
    required this.ultimaPosicionSegundos,
    required this.completado,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppUserContentState.fromLocal(LocalUserContentState state) {
    return AppUserContentState(
      uuidUserContentState: state.uuidUserContentState,
      uuidProfile: state.uuidProfile,
      uuidContentItem: state.uuidContentItem,
      favorito: state.favorito,
      progresoPorcentaje: state.progresoPorcentaje,
      ultimaPosicionSegundos: state.ultimaPosicionSegundos,
      completado: state.completado,
      startedAt: state.startedAt,
      completedAt: state.completedAt,
      createdAt: state.createdAt,
      updatedAt: state.updatedAt,
      deletedAt: state.deletedAt,
      syncedAt: state.syncedAt,
    );
  }

  final String uuidUserContentState;
  final String uuidProfile;
  final String uuidContentItem;
  final bool favorito;
  final int progresoPorcentaje;
  final int ultimaPosicionSegundos;
  final bool completado;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get hasPendingSync => syncedAt == null || syncedAt!.isBefore(updatedAt);
}
