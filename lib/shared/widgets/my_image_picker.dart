import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

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

    return ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 84,
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
