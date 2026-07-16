import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import 'my_image_picker_permission_policy.dart';

class MyImagePicker {
  const MyImagePicker._();

  static Future<XFile?> pick(
    BuildContext context, {
    String title = 'Foto de perfil',
    Future<void> Function()? onRemovePhoto,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _ImageSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Elegir de galería',
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: 10),
                  _ImageSourceTile(
                    icon: Icons.photo_camera_outlined,
                    title: 'Tomar foto',
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ],
                if (onRemovePhoto != null) ...[
                  const SizedBox(height: 10),
                  _ImageSourceTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Quitar foto',
                    danger: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      onRemovePhoto();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return null;
    }
    if (!context.mounted) {
      return null;
    }

    final hasPermission = await _ensurePermission(context, source);
    if (!hasPermission || !context.mounted) {
      return null;
    }

    try {
      return ImagePicker().pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 84,
      );
    } catch (_) {
      if (context.mounted) {
        _showPermissionSnackBar(
          context,
          source == ImageSource.camera
              ? 'No se pudo abrir la cámara.'
              : 'No se pudo abrir la galería.',
        );
      }
      return null;
    }
  }

  static Future<bool> _ensurePermission(
    BuildContext context,
    ImageSource source,
  ) async {
    if (!imagePickerNeedsManualPermission(source, isWeb: kIsWeb)) {
      return true;
    }

    final status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    final shouldOpenSettings =
        status.isPermanentlyDenied || status.isRestricted;
    await _showPermissionDialog(
      context,
      title: 'Permiso de cámara',
      message: shouldOpenSettings
          ? 'Activa el permiso de cámara desde Ajustes para poder tomar una foto.'
          : 'Necesitamos permiso de cámara para tomar una foto.',
      actionLabel: shouldOpenSettings ? 'Abrir Ajustes' : 'Entendido',
      onAction: shouldOpenSettings ? openAppSettings : null,
    );

    return false;
  }

  static void _showPermissionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  static Future<void> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    Future<bool> Function()? onAction,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction?.call();
              },
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final background = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;

    return Material(
      color: background,
      borderRadius: AppRadius.medium,
      child: InkWell(
        borderRadius: AppRadius.medium,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: danger
                    ? AppColors.danger
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: danger ? AppColors.danger : null,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: danger
                    ? AppColors.danger
                    : Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
