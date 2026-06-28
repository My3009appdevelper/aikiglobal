import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/data/models/app_content_item.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_cover_image.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/my_image_picker.dart';

class AdminContentFormPage extends StatefulWidget {
  const AdminContentFormPage({super.key, this.item});

  final AppContentItem? item;

  @override
  State<AdminContentFormPage> createState() => _AdminContentFormPageState();
}

class _AdminContentFormPageState extends State<AdminContentFormPage> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _orderController = TextEditingController();

  String _type = 'course';
  bool _featured = false;
  bool _downloadable = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _coverLocalPath;
  String? _coverRemotePath;
  Uint8List? _coverPreviewBytes;
  String? _coverFileName;
  String? _coverContentType;
  late _ContentFormSnapshot _initialSnapshot;

  bool get _isEditing => widget.item != null;
  bool get _hasChanges => _currentSnapshot() != _initialSnapshot;
  bool get _canPublish =>
      _hasChanges || (widget.item?.status.trim().toLowerCase() != 'published');
  bool get _isPublished =>
      widget.item?.status.trim().toLowerCase() == 'published';
  bool get _isArchived => widget.item?.status.trim().toLowerCase() == 'archived';

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item == null) {
      _orderController.text = '0';
      _initialSnapshot = _currentSnapshot();
      _addChangeListeners();
      return;
    }

    _type = item.tipo;
    _featured = item.destacado;
    _downloadable = item.descargable;
    _titleController.text = item.titulo;
    _subtitleController.text = item.subtitulo ?? '';
    _descriptionController.text = item.descripcion ?? '';
    _coverLocalPath = item.coverPathLocal;
    _coverRemotePath = item.coverPathSupabase;
    _durationController.text = item.duracionSegundos == null
        ? ''
        : (item.duracionSegundos! / 60).round().toString();
    _orderController.text = item.orden.toString();
    _initialSnapshot = _currentSnapshot();
    _addChangeListeners();
  }

  @override
  void dispose() {
    _removeChangeListeners();
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _addChangeListeners() {
    _titleController.addListener(_handleFormChanged);
    _subtitleController.addListener(_handleFormChanged);
    _descriptionController.addListener(_handleFormChanged);
    _durationController.addListener(_handleFormChanged);
    _orderController.addListener(_handleFormChanged);
  }

  void _removeChangeListeners() {
    _titleController.removeListener(_handleFormChanged);
    _subtitleController.removeListener(_handleFormChanged);
    _descriptionController.removeListener(_handleFormChanged);
    _durationController.removeListener(_handleFormChanged);
    _orderController.removeListener(_handleFormChanged);
  }

  void _handleFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickCover() async {
    final pickedImage = await MyImagePicker.pick(
      context,
      title: 'Portada del contenido',
    );
    if (pickedImage == null || !mounted) {
      return;
    }

    final bytes = await pickedImage.readAsBytes();
    if (bytes.isEmpty) {
      if (!mounted) return;
      setState(() => _errorMessage = 'La imagen seleccionada está vacía.');
      return;
    }

    setState(() {
      _coverPreviewBytes = bytes;
      _coverFileName = pickedImage.name;
      _coverContentType = pickedImage.mimeType;
      _coverLocalPath = null;
      _coverRemotePath = null;
      _errorMessage = null;
    });
  }

  String? _selectedCoverPath() {
    final localPath = _coverLocalPath?.trim();
    if (localPath != null && localPath.isNotEmpty) {
      return localPath;
    }

    final remotePath = _coverRemotePath?.trim();
    if (remotePath != null && remotePath.isNotEmpty) {
      return remotePath;
    }

    return null;
  }

  String _draftStatusForSave() {
    final existingStatus = widget.item?.status.trim().toLowerCase();
    if (existingStatus != null && existingStatus.isNotEmpty) {
      return existingStatus;
    }

    return 'draft';
  }

  _ContentFormSnapshot _currentSnapshot() {
    return _ContentFormSnapshot(
      type: _type,
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      description: _descriptionController.text.trim(),
      coverLocalPath: _coverLocalPath?.trim() ?? '',
      coverRemotePath: _coverRemotePath?.trim() ?? '',
      pendingCoverFileName: _coverFileName?.trim() ?? '',
      durationMinutes: _durationController.text.trim(),
      order: _orderController.text.trim(),
      featured: _featured,
      downloadable: _downloadable,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        imageOpacity: 0.035,
        child: SafeArea(
          bottom: false,
          child: AppResponsiveContainer(
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormHeader(
                          title: _isEditing
                              ? 'Editar contenido'
                              : 'Nuevo contenido',
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CoverPickerCard(
                          imagePath: _selectedCoverPath(),
                          previewBytes: _coverPreviewBytes,
                          onTap: _pickCover,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _FormCard(
                          child: Column(
                            children: [
                              _DropdownField(
                                label: 'Tipo',
                                value: _type,
                                items: _contentTypes,
                                labelFor: _typeLabel,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _type = value);
                                  }
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _titleController,
                                hintText: 'Título',
                                prefixIcon: Icons.title_rounded,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _subtitleController,
                                hintText: 'Subtítulo',
                                prefixIcon: Icons.notes_rounded,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _descriptionController,
                                hintText: 'Descripción',
                                prefixIcon: Icons.description_outlined,
                                minLines: 3,
                                maxLines: 6,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _durationController,
                                      hintText: 'Duración en minutos',
                                      prefixIcon: Icons.schedule_rounded,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _orderController,
                                      hintText: 'Orden',
                                      prefixIcon: Icons.sort_rounded,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _FormCard(
                          child: Column(
                            children: [
                              _SwitchRow(
                                title: 'Destacado',
                                subtitle:
                                    'Puede aparecer en espacios recomendados.',
                                value: _featured,
                                onChanged: (value) =>
                                    setState(() => _featured = value),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _SwitchRow(
                                title: 'Descargable',
                                subtitle:
                                    'Disponible para descarga cuando se conecte media.',
                                value: _downloadable,
                                onChanged: (value) =>
                                    setState(() => _downloadable = value),
                              ),
                            ],
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AppPrimaryButton(
                          label: _isSaving
                              ? 'Guardando...'
                              : (_isEditing
                                    ? 'Guardar cambios'
                                    : 'Guardar borrador'),
                          icon: Icons.check_rounded,
                          onPressed: _isSaving || !_hasChanges
                              ? null
                              : () => _save(_draftStatusForSave()),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (_isEditing && _isPublished) ...[
                          AppSecondaryButton(
                            label: 'Hacer borrador',
                            icon: Icons.edit_note_rounded,
                            onPressed: _isSaving ? null : () => _save('draft'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppSecondaryButton(
                            label: 'Archivar',
                            icon: Icons.archive_rounded,
                            onPressed: _isSaving ? null : () => _save('archived'),
                          ),
                        ] else ...[
                          AppSecondaryButton(
                            label: 'Publicar',
                            icon: Icons.publish_rounded,
                            onPressed: _isSaving || !_canPublish
                                ? null
                                : () => _save('published'),
                          ),
                          if (_isEditing && !_isArchived) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppSecondaryButton(
                              label: 'Archivar',
                              icon: Icons.archive_rounded,
                              onPressed: _isSaving ? null : () => _save('archived'),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(String status) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Escribe un título para continuar.');
      return;
    }

    final controller = AppDataScope.contentItems(context);
    final profile = AppDataScope.currentProfile(context).profile;
    final durationMinutes = int.tryParse(_durationController.text.trim());
    final order = int.tryParse(_orderController.text.trim()) ?? 0;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await controller.saveContentItem(
        uuidContentItem: widget.item?.uuidContentItem,
        tipo: _type,
        titulo: title,
        subtitulo: _subtitleController.text,
        descripcion: _descriptionController.text,
        coverPathSupabase: _coverRemotePath,
        coverPathLocal: _coverPreviewBytes == null ? _coverLocalPath : null,
        coverBytes: _coverPreviewBytes,
        coverFileName: _coverFileName,
        coverContentType: _coverContentType,
        status: status,
        destacado: _featured,
        descargable: _downloadable,
        duracionSegundos: durationMinutes == null || durationMinutes <= 0
            ? null
            : durationMinutes * 60,
        orden: order,
        createdBy: profile?.uuidProfile,
        syncAfterSave: true,
      );

      if (!mounted) return;
      _coverPreviewBytes = null;
      _coverFileName = null;
      _coverContentType = null;
      _initialSnapshot = _currentSnapshot();
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage =
            'No se pudo guardar el contenido. Revisa tus permisos o conexión.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title, required this.onBack});

  final String title;
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
      ],
    );
  }
}

class _CoverPickerCard extends StatelessWidget {
  const _CoverPickerCard({
    required this.imagePath,
    required this.previewBytes,
    required this.onTap,
  });

  final String? imagePath;
  final Uint8List? previewBytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return AppInteractive(
      tooltip: 'Cambiar portada',
      borderRadius: AppRadius.large,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 210,
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.92),
          borderRadius: AppRadius.large,
          border: Border.all(color: stroke),
          boxShadow: AppShadows.soft(brightness),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (previewBytes != null)
              Image.memory(previewBytes!, fit: BoxFit.cover)
            else if (imagePath != null)
              AppCoverImage(
                imagePath: imagePath,
                resolveImageUrl: AppDataScope.contentItems(
                  context,
                ).resolveCoverImageUrl,
                fallback: _coverFallback(context),
              )
            else
              _coverFallback(context),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.02),
                    AppColors.black.withValues(alpha: 0.38),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          imagePath == null && previewBytes == null
                              ? 'Agregar portada'
                              : 'Cambiar portada',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Selecciona una imagen para este contenido.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _coverFallback(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.sandLight,
    child: AppLogo(
      width: 168,
      light: Theme.of(context).brightness == Brightness.dark,
    ),
  );
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: child,
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final String Function(String value) labelFor;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(labelFor(item)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

const _contentTypes = [
  'course',
  'meditation',
  'audio',
  'sound',
  'event',
  'session',
];

String _typeLabel(String tipo) {
  return switch (tipo) {
    'course' => 'Curso',
    'meditation' => 'Meditación',
    'audio' => 'Audio',
    'sound' => 'Sonido',
    'event' => 'Evento',
    'session' => 'Sesión',
    _ => tipo,
  };
}

class _ContentFormSnapshot {
  const _ContentFormSnapshot({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.coverLocalPath,
    required this.coverRemotePath,
    required this.pendingCoverFileName,
    required this.durationMinutes,
    required this.order,
    required this.featured,
    required this.downloadable,
  });

  final String type;
  final String title;
  final String subtitle;
  final String description;
  final String coverLocalPath;
  final String coverRemotePath;
  final String pendingCoverFileName;
  final String durationMinutes;
  final String order;
  final bool featured;
  final bool downloadable;

  @override
  bool operator ==(Object other) {
    return other is _ContentFormSnapshot &&
        other.type == type &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.description == description &&
        other.coverLocalPath == coverLocalPath &&
        other.coverRemotePath == coverRemotePath &&
        other.pendingCoverFileName == pendingCoverFileName &&
        other.durationMinutes == durationMinutes &&
        other.order == order &&
        other.featured == featured &&
        other.downloadable == downloadable;
  }

  @override
  int get hashCode => Object.hash(
    type,
    title,
    subtitle,
    description,
    coverLocalPath,
    coverRemotePath,
    pendingCoverFileName,
    durationMinutes,
    order,
    featured,
    downloadable,
  );
}
