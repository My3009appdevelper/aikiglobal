import 'package:flutter/material.dart';

import '../../core/data/models/app_profile.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/current_profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_primary_button.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../../shared/widgets/app_responsive_container.dart';
import '../../shared/widgets/my_image.dart';
import '../../shared/widgets/my_image_picker.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  String? _loadedProfileId;
  String _savedName = '';
  bool _isSaving = false;
  bool _isPhotoSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleNameChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile(CurrentProfileController controller) async {
    await controller.syncWithRemote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        imageOpacity: 0.035,
        child: SafeArea(
          bottom: false,
          child: AppResponsiveContainer(
            child: AnimatedBuilder(
              animation: AppDataScope.currentProfile(context),
              builder: (context, _) {
                final controller = AppDataScope.currentProfile(context);
                final profile = controller.profile;
                _syncName(profile);

                return AppRefreshIndicator(
                  onRefresh: () => _refreshProfile(controller),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 130),
                          child: profile == null
                              ? const _EmptyProfileState()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _PersonalDataHeader(
                                      onBack: () => Navigator.of(context).pop(),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    _AvatarSection(
                                      profile: profile,
                                      nameController: _nameController,
                                      nameFocusNode: _nameFocusNode,
                                      resolveImageUrl: controller
                                          .createProfilePhotoSignedUrl,
                                      isSaving: _isSaving,
                                      isPhotoSaving: _isPhotoSaving,
                                      hasNameChanges: _hasNameChanges,
                                      errorMessage: _errorMessage,
                                      onSaveName: () => _saveName(controller),
                                      onChangePhoto: _isPhotoSaving
                                          ? null
                                          : () =>
                                                _pickAndUploadPhoto(controller),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    _EmailInfoCard(email: profile.email),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _syncName(AppProfile? profile) {
    if (profile == null) {
      return;
    }

    final profileName = profile.nombre?.trim() ?? '';
    final isNewProfile = profile.uuidProfile != _loadedProfileId;
    if (!isNewProfile && (_hasNameChanges || profileName == _savedName)) {
      return;
    }

    _loadedProfileId = profile.uuidProfile;
    _savedName = profileName;
    _nameController.text = profileName;
    _errorMessage = null;
  }

  bool get _hasNameChanges => _nameController.text.trim() != _savedName;

  void _handleNameChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickAndUploadPhoto(CurrentProfileController controller) async {
    final profile = controller.profile;
    final pickedImage = await MyImagePicker.pick(
      context,
      onRemovePhoto: profile != null && _hasPhoto(profile)
          ? () => _removePhoto(controller)
          : null,
    );
    if (pickedImage == null || !mounted) {
      return;
    }

    setState(() => _isPhotoSaving = true);

    try {
      final bytes = await pickedImage.readAsBytes();
      if (bytes.isEmpty) {
        throw StateError('La imagen seleccionada está vacía.');
      }

      await controller.updateProfilePhoto(
        bytes: bytes,
        fileName: pickedImage.name,
        contentType: pickedImage.mimeType,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Foto de perfil actualizada.'),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('No se pudo subir la foto. Inténtalo nuevamente.'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isPhotoSaving = false);
      }
    }
  }

  Future<void> _saveName(CurrentProfileController controller) async {
    final name = _nameController.text.trim();
    if (!_hasNameChanges) {
      return;
    }

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Escribe tu nombre para guardar.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await controller.updateEditableProfile(
        nombre: name,
        syncAfterUpdate: true,
      );
      if (!mounted) return;
      _savedName = name;
      _nameFocusNode.unfocus();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Tus datos se guardaron correctamente.'),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage =
            'No se pudieron guardar tus datos. Inténtalo nuevamente.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _removePhoto(CurrentProfileController controller) async {
    setState(() => _isPhotoSaving = true);
    try {
      await controller.removeProfilePhoto();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Foto de perfil eliminada.'),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('No se pudo quitar la foto por el momento.'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isPhotoSaving = false);
      }
    }
  }
}

class _PersonalDataHeader extends StatelessWidget {
  const _PersonalDataHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppInteractive(
          tooltip: 'Regresar',
          borderRadius: AppRadius.full,
          onTap: onBack,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.82),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Datos personales',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.profile,
    required this.nameController,
    required this.nameFocusNode,
    required this.resolveImageUrl,
    required this.isSaving,
    required this.isPhotoSaving,
    required this.hasNameChanges,
    required this.errorMessage,
    required this.onSaveName,
    required this.onChangePhoto,
  });

  final AppProfile profile;
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final Future<String?> Function(String imagePath) resolveImageUrl;
  final bool isSaving;
  final bool isPhotoSaving;
  final bool hasNameChanges;
  final String? errorMessage;
  final VoidCallback onSaveName;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              MyImage(
                imagePath: _profilePhotoPath(profile),
                initials: _initialsFor(profile),
                resolveImageUrl: resolveImageUrl,
                size: 96,
              ),
              if (isPhotoSaving)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -12,
                bottom: -4,
                child: _AvatarActionButton(
                  tooltip: 'Cambiar foto',
                  icon: Icons.edit_rounded,
                  surface: surface,
                  onTap: onChangePhoto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: nameController,
              focusNode: nameFocusNode,
              enabled: !isSaving,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSaveName(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                suffixIcon: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          AppPrimaryButton(
            label: isSaving ? 'Guardando...' : 'Guardar nombre',
            icon: Icons.check_rounded,
            expand: false,
            height: 42,
            onPressed: isSaving || !hasNameChanges ? null : onSaveName,
          ),
        ],
      ),
    );
  }
}

class _AvatarActionButton extends StatelessWidget {
  const _AvatarActionButton({
    required this.tooltip,
    required this.icon,
    required this.surface,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color surface;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = Theme.of(context).colorScheme.primary;
    final foreground = Theme.of(context).colorScheme.onPrimary;

    return AppInteractive(
      tooltip: enabled ? tooltip : null,
      borderRadius: AppRadius.full,
      pressedScale: 0.95,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.42,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: enabled ? color : color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: surface, width: 3),
          ),
          child: Icon(icon, size: 17, color: enabled ? foreground : color),
        ),
      ),
    );
  }
}

class _EmailInfoCard extends StatelessWidget {
  const _EmailInfoCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Icon(
                    Icons.mail_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    'Correo',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Text(
                    email,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProfileState extends StatelessWidget {
  const _EmptyProfileState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Text(
          'No se pudo cargar tu perfil.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

bool _hasPhoto(AppProfile profile) {
  return (profile.fotoPathLocal?.trim().isNotEmpty ?? false) ||
      (profile.fotoPathSupabase?.trim().isNotEmpty ?? false);
}

String? _profilePhotoPath(AppProfile profile) {
  final localPath = profile.fotoPathLocal?.trim();
  if (localPath != null && localPath.isNotEmpty) {
    return localPath;
  }

  final remotePath = profile.fotoPathSupabase?.trim();
  if (remotePath != null && remotePath.isNotEmpty) {
    return remotePath;
  }

  return null;
}

String _initialsFor(AppProfile profile) {
  final source = profile.nombre?.trim().isNotEmpty == true
      ? profile.nombre!.trim()
      : profile.email.trim();
  final parts = source
      .split(RegExp(r'\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList();

  if (parts.isEmpty) {
    return 'A';
  }

  final first = parts.first.characters.first.toUpperCase();
  if (parts.length == 1) {
    return first;
  }

  return '$first${parts.last.characters.first.toUpperCase()}';
}
