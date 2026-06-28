class ContentMediaFileMetadata {
  const ContentMediaFileMetadata({
    required this.tipo,
    required this.titulo,
    required this.contentType,
  });

  factory ContentMediaFileMetadata.fromFileName(
    String fileName, {
    String? contentType,
  }) {
    final metadata = tryParse(fileName, contentType: contentType);
    if (metadata == null) {
      throw ArgumentError('El tipo de archivo no es válido.');
    }

    return metadata;
  }

  static ContentMediaFileMetadata? tryParse(
    String fileName, {
    String? contentType,
  }) {
    final cleanFileName = fileName.trim();
    final tipo = _typeFromFileName(cleanFileName);
    if (tipo == null) {
      return null;
    }

    return ContentMediaFileMetadata(
      tipo: tipo,
      titulo: _titleFromFileName(cleanFileName),
      contentType: _contentTypeByType[tipo] ?? contentType,
    );
  }

  static bool isSupportedType(String value) {
    return _contentTypeByType.containsKey(value.trim().toLowerCase());
  }

  static bool isVideoType(String value) {
    return _videoTypes.contains(value.trim().toLowerCase());
  }

  final String tipo;
  final String titulo;
  final String? contentType;
}

const _contentTypeByType = {
  'mp4': 'video/mp4',
  'mov': 'video/quicktime',
  'm4v': 'video/x-m4v',
  'mp3': 'audio/mpeg',
  'm4a': 'audio/mp4',
  'aac': 'audio/aac',
  'wav': 'audio/wav',
  'ogg': 'audio/ogg',
};

const _videoTypes = {'mp4', 'mov', 'm4v'};

String? _typeFromFileName(String fileName) {
  final name = fileName.split(RegExp(r'[\\/]')).last.toLowerCase();
  final dotIndex = name.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == name.length - 1) {
    return null;
  }

  final extension = name.substring(dotIndex + 1);
  return ContentMediaFileMetadata.isSupportedType(extension) ? extension : null;
}

String _titleFromFileName(String fileName) {
  final name = fileName.split(RegExp(r'[\\/]')).last;
  final dotIndex = name.lastIndexOf('.');
  final title = dotIndex > 0 ? name.substring(0, dotIndex).trim() : name.trim();
  return title.isEmpty ? 'Archivo' : title;
}
