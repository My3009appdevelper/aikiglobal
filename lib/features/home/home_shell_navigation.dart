import 'package:flutter/foundation.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/models/app_content_item.dart';
import '../../shared/widgets/app_bottom_nav_bar.dart';
import '../explorar/models/content_item.dart';

int resolveHomeShellIndex({
  required int currentIndex,
  required List<AppBottomNavItem> currentItems,
  required List<AppBottomNavItem> nextItems,
}) {
  if (nextItems.isEmpty) {
    return 0;
  }

  final fallbackIndex = currentIndex.clamp(0, nextItems.length - 1);
  if (currentIndex < 0 || currentIndex >= currentItems.length) {
    return fallbackIndex;
  }

  final currentLabel = currentItems[currentIndex].label;
  final matchingIndex = nextItems.indexWhere(
    (item) => item.label == currentLabel,
  );

  return matchingIndex == -1 ? fallbackIndex : matchingIndex;
}

ContentItem notificationContentItemForDetail(AppContentItem item) {
  return ContentItem(
    uuidContentItem: item.uuidContentItem,
    title: item.titulo,
    type: _displayContentType(item.tipo),
    duration: _formatContentDuration(item.duracionSegundos),
    imageAsset: _fallbackContentAsset(item.tipo),
    imagePath: _contentCoverPath(item),
    description: item.descripcion ?? item.subtitulo,
    isNew: item.destacado,
    descargable: item.descargable,
  );
}

String _displayContentType(String value) {
  return switch (value.trim().toLowerCase()) {
    'course' => 'Curso',
    'meditation' => 'Meditación',
    'event' => 'Evento',
    'ambient_sound' || 'sound' || 'sonido' => 'Sonido',
    'audio' => 'Audio',
    'session' => 'Sesión',
    _ => value,
  };
}

String _formatContentDuration(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return 'Disponible';
  }

  final totalMinutes = (seconds / 60).round();
  if (totalMinutes < 60) {
    return '$totalMinutes min';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
}

String? _contentCoverPath(AppContentItem item) {
  if (!kIsWeb) {
    final localPath = item.coverPathLocal?.trim();
    if (localPath != null && localPath.isNotEmpty) {
      return localPath;
    }
  }

  final remotePath = item.coverPathSupabase?.trim();
  return remotePath == null || remotePath.isEmpty ? null : remotePath;
}

String _fallbackContentAsset(String tipo) {
  return switch (tipo.trim().toLowerCase()) {
    'course' => AppAssets.curso1,
    'meditation' => AppAssets.meditacion1,
    'event' => AppAssets.evento1,
    _ => AppAssets.audio1,
  };
}
