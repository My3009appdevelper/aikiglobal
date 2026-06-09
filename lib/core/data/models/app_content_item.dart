import '../local/app_database.dart';

class AppContentItem {
  const AppContentItem({
    required this.uuidContentItem,
    required this.tipo,
    required this.titulo,
    required this.status,
    required this.destacado,
    required this.descargable,
    required this.orden,
    required this.createdAt,
    required this.updatedAt,
    this.subtitulo,
    this.descripcion,
    this.coverPathSupabase,
    this.coverPathLocal,
    this.duracionSegundos,
    this.createdBy,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppContentItem.fromLocal(LocalContentItem item) {
    return AppContentItem(
      uuidContentItem: item.uuidContentItem,
      tipo: item.tipo,
      titulo: item.titulo,
      subtitulo: item.subtitulo,
      descripcion: item.descripcion,
      coverPathSupabase: item.coverPathSupabase,
      coverPathLocal: item.coverPathLocal,
      status: item.status,
      destacado: item.destacado,
      descargable: item.descargable,
      duracionSegundos: item.duracionSegundos,
      orden: item.orden,
      createdBy: item.createdBy,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      deletedAt: item.deletedAt,
      syncedAt: item.syncedAt,
    );
  }

  final String uuidContentItem;
  final String tipo;
  final String titulo;
  final String? subtitulo;
  final String? descripcion;
  final String? coverPathSupabase;
  final String? coverPathLocal;
  final String status;
  final bool destacado;
  final bool descargable;
  final int? duracionSegundos;
  final int orden;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get isPublished => status == 'published' && deletedAt == null;
  bool get isDraft => status == 'draft' && deletedAt == null;
  bool get isArchived => status == 'archived' || deletedAt != null;
  bool get hasPendingSync => syncedAt == null || syncedAt!.isBefore(updatedAt);
}
