import '../local/app_database.dart';

class AppContentMedia {
  const AppContentMedia({
    required this.uuidContentMedia,
    required this.uuidContentItem,
    required this.tipo,
    required this.storagePathSupabase,
    required this.orden,
    required this.createdAt,
    required this.updatedAt,
    this.titulo,
    this.storagePathLocal,
    this.duracionSegundos,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppContentMedia.fromLocal(LocalContentMedia media) {
    return AppContentMedia(
      uuidContentMedia: media.uuidContentMedia,
      uuidContentItem: media.uuidContentItem,
      tipo: media.tipo,
      titulo: media.titulo,
      storagePathSupabase: media.storagePathSupabase,
      storagePathLocal: media.storagePathLocal,
      duracionSegundos: media.duracionSegundos,
      orden: media.orden,
      createdAt: media.createdAt,
      updatedAt: media.updatedAt,
      deletedAt: media.deletedAt,
      syncedAt: media.syncedAt,
    );
  }

  final String uuidContentMedia;
  final String uuidContentItem;
  final String tipo;
  final String? titulo;
  final String storagePathSupabase;
  final String? storagePathLocal;
  final int? duracionSegundos;
  final int orden;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get isPublishable {
    return deletedAt == null && storagePathSupabase.trim().isNotEmpty;
  }

  bool get hasPendingSync => syncedAt == null || syncedAt!.isBefore(updatedAt);
}
