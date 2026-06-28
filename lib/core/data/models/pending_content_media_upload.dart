import 'dart:io';
import 'dart:typed_data';

const _unset = Object();

class PendingContentMediaUpload {
  const PendingContentMediaUpload({
    required this.uuidContentMedia,
    required this.tipo,
    required this.titulo,
    required this.fileName,
    required this.contentType,
    required this.orden,
    this.duracionSegundos,
    this.localPath,
    this.bytes,
  });

  final String uuidContentMedia;
  final String tipo;
  final String titulo;
  final String fileName;
  final String? contentType;
  final int orden;
  final int? duracionSegundos;
  final String? localPath;
  final Uint8List? bytes;

  PendingContentMediaUpload copyWith({
    String? titulo,
    Object? duracionSegundos = _unset,
  }) {
    return PendingContentMediaUpload(
      uuidContentMedia: uuidContentMedia,
      tipo: tipo,
      titulo: titulo ?? this.titulo,
      fileName: fileName,
      contentType: contentType,
      orden: orden,
      duracionSegundos: identical(duracionSegundos, _unset)
          ? this.duracionSegundos
          : duracionSegundos as int?,
      localPath: localPath,
      bytes: bytes,
    );
  }

  Future<Uint8List> readBytes() async {
    final deferredBytes = bytes;
    if (deferredBytes != null) {
      return deferredBytes;
    }

    final cleanPath = localPath?.trim();
    if (cleanPath == null || cleanPath.isEmpty) {
      throw StateError('No se pudo leer el archivo seleccionado.');
    }

    final file = File(cleanPath);
    return file.readAsBytes();
  }
}
