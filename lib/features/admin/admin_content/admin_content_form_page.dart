import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/data/common/supabase_error_messages.dart';
import '../../../core/data/media/content_media_duration_reader.dart';
import '../../../core/data/models/app_content_item.dart';
import '../../../core/data/models/app_content_media.dart';
import '../../../core/data/models/content_media_file_metadata.dart';
import '../../../core/data/models/content_media_upload_limits.dart';
import '../../../core/data/models/pending_content_media_upload.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_saving_overlay.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_cover_image.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/my_image_picker.dart';
import 'content_media_duration_text.dart';
import 'content_media_form_draft.dart';
import 'content_media_metadata_policy.dart';

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
  final _mediaDurationReader = const ContentMediaDurationReader();

  String _type = 'meditation';
  bool _featured = false;
  bool _downloadable = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _coverLocalPath;
  String? _coverRemotePath;
  Uint8List? _coverPreviewBytes;
  String? _coverFileName;
  String? _coverContentType;
  late String _uuidContentItem;
  late _ContentFormSnapshot _initialSnapshot;
  bool _mediaWatchInitialized = false;
  final List<PendingContentMediaUpload> _pendingMedia = [];
  final Set<String> _pendingRemovedMediaIds = <String>{};
  final Map<String, ContentMediaMetadataEdit> _mediaEdits = {};

  bool get _isEditing => widget.item != null;
  bool get _hasChanges =>
      _currentSnapshot() != _initialSnapshot || _hasMediaChanges;
  bool get _hasMediaChanges =>
      _pendingMedia.isNotEmpty ||
      _pendingRemovedMediaIds.isNotEmpty ||
      _mediaEdits.isNotEmpty;
  bool get _mediaMetadataEditable => contentMediaMetadataIsEditable(_type);
  bool get _canPublish =>
      _hasChanges || (widget.item?.status.trim().toLowerCase() != 'published');
  bool get _isPublished =>
      widget.item?.status.trim().toLowerCase() == 'published';
  bool get _isArchived =>
      widget.item?.status.trim().toLowerCase() == 'archived';

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _uuidContentItem = item?.uuidContentItem ?? _generateUuidV4();
    if (item == null) {
      _orderController.text = '0';
      _initialSnapshot = _currentSnapshot();
      _addChangeListeners();
      return;
    }

    _type = _contentTypeForForm(item.tipo);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mediaWatchInitialized) {
      return;
    }

    _mediaWatchInitialized = true;
    final mediaController = AppDataScope.contentMedia(context);
    mediaController.watchForContent(_uuidContentItem);
    if (_isEditing) {
      unawaited(mediaController.pullFromRemote());
    }
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

  ContentMediaFormDraft _mediaDraft(List<AppContentMedia> media) {
    return ContentMediaFormDraft(
      persistedMedia: media,
      pendingUploads: _pendingMedia,
      removedMediaIds: _pendingRemovedMediaIds,
    );
  }

  int _nextMediaOrder() {
    final draft = _mediaDraft(AppDataScope.contentMedia(context).items);
    return draft.nextSortOrder;
  }

  int? _contentDurationSecondsFromForm() {
    final durationMinutes = int.tryParse(_durationController.text.trim());
    if (durationMinutes == null || durationMinutes <= 0) {
      return null;
    }

    return durationMinutes * 60;
  }

  @override
  Widget build(BuildContext context) {
    final contentMediaController = AppDataScope.contentMedia(context);

    return Scaffold(
      body: AppSavingOverlay(
        isSaving: _isSaving,
        child: AppBackground(
          imageOpacity: 0.035,
          child: SafeArea(
            bottom: false,
            child: AppResponsiveContainer(
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                                      setState(() {
                                        _type = value;
                                        if (!contentMediaMetadataIsEditable(
                                          value,
                                        )) {
                                          _mediaEdits.clear();
                                        }
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppTextField(
                                  controller: _titleController,
                                  hintText: 'Título',
                                  labelText: 'Título',
                                  prefixIcon: Icons.title_rounded,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppTextField(
                                  controller: _subtitleController,
                                  hintText: 'Subtítulo',
                                  labelText: 'Subtítulo',
                                  prefixIcon: Icons.notes_rounded,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppTextField(
                                  controller: _descriptionController,
                                  hintText: 'Descripción',
                                  labelText: 'Descripción',
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
                          const SizedBox(height: AppSpacing.lg),
                          AnimatedBuilder(
                            animation: contentMediaController,
                            builder: (context, _) {
                              final mediaDraft = _mediaDraft(
                                contentMediaController.items,
                              );
                              return _MediaFilesCard(
                                items: mediaDraft.visiblePersistedMedia,
                                pendingItems: mediaDraft.visiblePendingUploads,
                                mediaEdits: _mediaEdits,
                                metadataEditable: _mediaMetadataEditable,
                                contentTitle: _titleController.text.trim(),
                                contentDurationSeconds:
                                    _contentDurationSecondsFromForm(),
                                onAdd: _isSaving ? null : _addMedia,
                                onRemove: _isSaving
                                    ? null
                                    : _markMediaForRemoval,
                                onMediaTitleChanged: _isSaving
                                    ? null
                                    : _updateExistingMediaTitle,
                                onMediaDurationChanged: _isSaving
                                    ? null
                                    : _updateExistingMediaDuration,
                                onRemovePending: _isSaving
                                    ? null
                                    : _removePendingMedia,
                                onPendingTitleChanged: _isSaving
                                    ? null
                                    : _updatePendingMediaTitle,
                                onPendingDurationChanged: _isSaving
                                    ? null
                                    : _updatePendingMediaDuration,
                              );
                            },
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
                              onPressed: _isSaving
                                  ? null
                                  : () => _save('draft'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppSecondaryButton(
                              label: 'Archivar',
                              icon: Icons.archive_rounded,
                              onPressed: _isSaving
                                  ? null
                                  : () => _save('archived'),
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
                                onPressed: _isSaving
                                    ? null
                                    : () => _save('archived'),
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
      ),
    );
  }

  Future<void> _addMedia() async {
    if (_isSaving) {
      return;
    }

    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'mp4',
        'mov',
        'm4v',
        'mp3',
        'm4a',
        'aac',
        'wav',
        'ogg',
      ],
      withData: false,
    );
    if (picked == null || picked.files.isEmpty || !mounted) {
      return;
    }

    final file = picked.files.single;
    final metadata = ContentMediaFileMetadata.tryParse(file.name);
    if (metadata == null) {
      setState(
        () => _errorMessage =
            'Selecciona un archivo de video o audio compatible.',
      );
      return;
    }

    final sizeError = validateContentMediaFileSize(
      tipo: metadata.tipo,
      sizeBytes: file.size,
    );
    if (sizeError != null) {
      setState(() => _errorMessage = sizeError);
      return;
    }

    final localPath = file.path?.trim();
    final bytes = file.bytes;
    if ((localPath == null || localPath.isEmpty) &&
        (bytes == null || bytes.isEmpty)) {
      setState(
        () => _errorMessage =
            'No se pudo leer el archivo seleccionado. Inténtalo de nuevo.',
      );
      return;
    }

    final order = _nextMediaOrder();
    final durationSeconds = await _mediaDurationReader.readDurationSeconds(
      localPath,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _pendingMedia.add(
        PendingContentMediaUpload(
          uuidContentMedia: _generateUuidV4(),
          tipo: metadata.tipo,
          titulo: metadata.titulo,
          fileName: file.name,
          contentType: metadata.contentType,
          orden: order,
          duracionSegundos: durationSeconds,
          localPath: localPath,
          bytes: bytes,
          fileSizeBytes: file.size,
        ),
      );
      _errorMessage = null;
    });
  }

  void _removePendingMedia(PendingContentMediaUpload media) {
    setState(() {
      _pendingMedia.removeWhere(
        (item) => item.uuidContentMedia == media.uuidContentMedia,
      );
      _errorMessage = null;
    });
  }

  void _updatePendingMediaTitle(PendingContentMediaUpload media, String title) {
    if (!_mediaMetadataEditable) {
      return;
    }

    final index = _pendingMedia.indexWhere(
      (item) => item.uuidContentMedia == media.uuidContentMedia,
    );
    if (index < 0) {
      return;
    }

    setState(() {
      _pendingMedia[index] = _pendingMedia[index].copyWith(titulo: title);
      _errorMessage = null;
    });
  }

  void _updatePendingMediaDuration(
    PendingContentMediaUpload media,
    String minutesText,
  ) {
    if (!_mediaMetadataEditable) {
      return;
    }

    final index = _pendingMedia.indexWhere(
      (item) => item.uuidContentMedia == media.uuidContentMedia,
    );
    if (index < 0) {
      return;
    }

    setState(() {
      _pendingMedia[index] = _pendingMedia[index].copyWith(
        duracionSegundos: contentMediaDurationMinutesTextToSeconds(minutesText),
      );
      _errorMessage = null;
    });
  }

  ContentMediaMetadataEdit _mediaEditFor(AppContentMedia media) {
    return _mediaEdits[media.uuidContentMedia] ??
        ContentMediaMetadataEdit.fromMedia(media);
  }

  void _setMediaEdit(AppContentMedia media, ContentMediaMetadataEdit edit) {
    if (_isSaving) {
      return;
    }

    setState(() {
      if (edit.hasChangesFrom(media)) {
        _mediaEdits[media.uuidContentMedia] = edit;
      } else {
        _mediaEdits.remove(media.uuidContentMedia);
      }
      _errorMessage = null;
    });
  }

  void _updateExistingMediaTitle(AppContentMedia media, String title) {
    if (!_mediaMetadataEditable) {
      return;
    }

    _setMediaEdit(media, _mediaEditFor(media).copyWith(titulo: title));
  }

  void _updateExistingMediaDuration(AppContentMedia media, String minutesText) {
    if (!_mediaMetadataEditable) {
      return;
    }

    _setMediaEdit(
      media,
      _mediaEditFor(media).copyWith(
        duracionSegundos: contentMediaDurationMinutesTextToSeconds(minutesText),
      ),
    );
  }

  void _markMediaForRemoval(AppContentMedia media) {
    if (_isSaving) {
      return;
    }

    setState(() {
      _pendingRemovedMediaIds.add(media.uuidContentMedia);
      _mediaEdits.remove(media.uuidContentMedia);
      _errorMessage = null;
    });
  }

  Future<bool> _save(
    String status, {
    bool popOnSuccess = true,
    bool validateMediaForPublish = true,
    bool showSavingState = true,
  }) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorMessage = 'Escribe un título para continuar.');
      return false;
    }

    final mediaController = AppDataScope.contentMedia(context);
    final mediaDraft = _mediaDraft(mediaController.items);
    final hasUntitledMedia =
        _mediaMetadataEditable &&
        (mediaDraft.visiblePersistedMedia.any(
              (media) => _mediaEditFor(media).titulo.trim().isEmpty,
            ) ||
            mediaDraft.visiblePendingUploads.any(
              (media) => media.titulo.trim().isEmpty,
            ));
    if (hasUntitledMedia) {
      setState(() => _errorMessage = 'Escribe un título para cada archivo.');
      return false;
    }

    final controller = AppDataScope.contentItems(context);
    final profile = AppDataScope.currentProfile(context).profile;
    final cleanStatus = status.trim().toLowerCase();
    final hasPendingMedia = mediaDraft.visiblePendingUploads.isNotEmpty;
    final hasExistingMedia = mediaDraft.hasVisiblePublishablePersistedMedia;
    if (validateMediaForPublish && cleanStatus == 'published') {
      if (!mediaDraft.hasPublishableMediaAfterChanges) {
        if (!mounted) return false;
        setState(
          () => _errorMessage = 'Agrega al menos un archivo antes de publicar.',
        );
        return false;
      }
    }

    final contentDurationSeconds = _contentDurationSecondsFromForm();
    final order = int.tryParse(_orderController.text.trim()) ?? 0;
    final delayPublishUntilMediaUpload =
        cleanStatus == 'published' && hasPendingMedia && !hasExistingMedia;
    final initialStatus = delayPublishUntilMediaUpload ? 'draft' : cleanStatus;
    var isApplyingMediaMetadata = false;
    var isUploadingPendingMedia = false;
    var isApplyingMediaRemovals = false;

    setState(() {
      if (showSavingState) {
        _isSaving = true;
      }
      _errorMessage = null;
    });

    try {
      await controller.saveContentItem(
        uuidContentItem: _uuidContentItem,
        tipo: _type,
        titulo: title,
        subtitulo: _subtitleController.text,
        descripcion: _descriptionController.text,
        coverPathSupabase: _coverRemotePath,
        coverPathLocal: _coverPreviewBytes == null ? _coverLocalPath : null,
        coverBytes: _coverPreviewBytes,
        coverFileName: _coverFileName,
        coverContentType: _coverContentType,
        status: initialStatus,
        destacado: _featured,
        descargable: _downloadable,
        duracionSegundos: contentDurationSeconds,
        orden: order,
        createdBy: profile?.uuidProfile,
        syncAfterSave: true,
      );

      if (!mounted) return false;
      _coverPreviewBytes = null;
      _coverFileName = null;
      _coverContentType = null;

      isApplyingMediaMetadata = _hasPendingMediaMetadataUpdates(
        mediaDraft,
        contentTitle: title,
        contentDurationSeconds: contentDurationSeconds,
      );
      await _applyPendingMediaMetadataEdits(
        contentTitle: title,
        contentDurationSeconds: contentDurationSeconds,
      );
      isApplyingMediaMetadata = false;

      isUploadingPendingMedia = _pendingMedia.isNotEmpty;
      await _uploadPendingMedia(
        contentTitle: title,
        contentDurationSeconds: contentDurationSeconds,
      );
      isUploadingPendingMedia = false;

      isApplyingMediaRemovals = _pendingRemovedMediaIds.isNotEmpty;
      await _applyPendingMediaRemovals();
      isApplyingMediaRemovals = false;

      if (delayPublishUntilMediaUpload) {
        await controller.updateStatus(
          _uuidContentItem,
          status: cleanStatus,
          syncAfterUpdate: true,
        );
      }

      if (!mounted) return false;
      _pendingRemovedMediaIds.clear();
      _initialSnapshot = _currentSnapshot();
      if (popOnSuccess) {
        Navigator.of(context).pop();
      } else {
        setState(() {});
      }
      return true;
    } catch (error) {
      if (!mounted) return false;
      debugPrint(
        'AdminContentFormPage.save error: ${supabaseErrorDebugLabel(error)}',
      );
      setState(
        () => _errorMessage = isUploadingPendingMedia
            ? contentMediaUploadErrorMessage(error)
            : isApplyingMediaMetadata
            ? 'No se pudieron guardar los datos de los archivos. Revisa tus permisos o conexión.'
            : isApplyingMediaRemovals
            ? 'No se pudieron quitar los archivos. Revisa tus permisos o conexión.'
            : 'No se pudo guardar el contenido. Revisa tus permisos o conexión.',
      );
      return false;
    } finally {
      if (mounted) {
        setState(() {
          if (showSavingState) {
            _isSaving = false;
          }
        });
      }
    }
  }

  bool _hasPendingMediaMetadataUpdates(
    ContentMediaFormDraft draft, {
    required String contentTitle,
    required int? contentDurationSeconds,
  }) {
    if (_mediaMetadataEditable) {
      return _mediaEdits.isNotEmpty;
    }

    return draft.visiblePersistedMedia.any((media) {
      final metadata = contentMediaMetadataForSave(
        contentType: _type,
        contentTitle: contentTitle,
        contentDurationSeconds: contentDurationSeconds,
        mediaTitle: media.titulo ?? '',
        mediaDurationSeconds: media.duracionSegundos,
      );
      return metadata.title != (media.titulo ?? '').trim() ||
          metadata.durationSeconds != media.duracionSegundos;
    });
  }

  Future<void> _applyPendingMediaMetadataEdits({
    required String contentTitle,
    required int? contentDurationSeconds,
  }) async {
    final mediaMetadataEditable = _mediaMetadataEditable;
    if (mediaMetadataEditable && _mediaEdits.isEmpty) {
      return;
    }

    final mediaController = AppDataScope.contentMedia(context);
    final visibleMedia = _mediaDraft(
      mediaController.items,
    ).visiblePersistedMedia;
    final visibleMediaById = {
      for (final media in visibleMedia) media.uuidContentMedia: media,
    };
    final edits = mediaMetadataEditable
        ? Map<String, ContentMediaMetadataEdit>.of(_mediaEdits)
        : {
            for (final media in visibleMedia)
              media.uuidContentMedia: ContentMediaMetadataEdit(
                uuidContentMedia: media.uuidContentMedia,
                titulo: contentMediaMetadataForSave(
                  contentType: _type,
                  contentTitle: contentTitle,
                  contentDurationSeconds: contentDurationSeconds,
                  mediaTitle: media.titulo ?? '',
                  mediaDurationSeconds: media.duracionSegundos,
                ).title,
                duracionSegundos: contentMediaMetadataForSave(
                  contentType: _type,
                  contentTitle: contentTitle,
                  contentDurationSeconds: contentDurationSeconds,
                  mediaTitle: media.titulo ?? '',
                  mediaDurationSeconds: media.duracionSegundos,
                ).durationSeconds,
              ),
          };

    for (final entry in edits.entries) {
      final media = visibleMediaById[entry.key];
      if (media == null) {
        if (!mounted) {
          return;
        }
        setState(() => _mediaEdits.remove(entry.key));
        continue;
      }

      final edit = entry.value;
      if (!edit.hasChangesFrom(media)) {
        if (!mounted) {
          return;
        }
        setState(() => _mediaEdits.remove(entry.key));
        continue;
      }

      await mediaController.updateMediaMetadata(
        uuidContentMedia: media.uuidContentMedia,
        tipo: media.tipo,
        titulo: edit.titulo,
        duracionSegundos: edit.duracionSegundos,
        orden: media.orden,
        syncAfterUpdate: true,
      );

      if (!mounted) {
        return;
      }
      setState(() => _mediaEdits.remove(entry.key));
    }
  }

  Future<void> _uploadPendingMedia({
    required String contentTitle,
    required int? contentDurationSeconds,
  }) async {
    if (_pendingMedia.isEmpty) {
      return;
    }

    final pendingMedia = List<PendingContentMediaUpload>.of(_pendingMedia);
    final mediaController = AppDataScope.contentMedia(context);

    for (final item in pendingMedia) {
      Uint8List? bytes;
      if (!item.hasLocalFileSource) {
        bytes = await item.readBytes();
        if (bytes.isEmpty) {
          throw StateError('El archivo seleccionado está vacío.');
        }
      }
      final metadata = contentMediaMetadataForSave(
        contentType: _type,
        contentTitle: contentTitle,
        contentDurationSeconds: contentDurationSeconds,
        mediaTitle: item.titulo,
        mediaDurationSeconds: item.duracionSegundos,
      );

      await mediaController.addMedia(
        uuidContentMedia: item.uuidContentMedia,
        uuidContentItem: _uuidContentItem,
        tipo: item.tipo,
        titulo: metadata.title,
        bytes: bytes,
        localPath: item.cleanLocalPath,
        fileName: item.fileName,
        contentType: item.contentType,
        duracionSegundos: metadata.durationSeconds,
        orden: item.orden,
        syncAfterSave: true,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _pendingMedia.removeWhere(
          (pending) => pending.uuidContentMedia == item.uuidContentMedia,
        );
      });
    }
  }

  Future<void> _applyPendingMediaRemovals() async {
    if (_pendingRemovedMediaIds.isEmpty) {
      return;
    }

    final mediaController = AppDataScope.contentMedia(context);
    final pendingIds = Set<String>.of(_pendingRemovedMediaIds);

    for (final uuidContentMedia in pendingIds) {
      await mediaController.archiveMedia(
        uuidContentMedia,
        syncAfterUpdate: true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _pendingRemovedMediaIds.remove(uuidContentMedia);
      });
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
                          'Selecciona una imagen.',
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

class _MediaFilesCard extends StatelessWidget {
  const _MediaFilesCard({
    required this.items,
    required this.pendingItems,
    required this.mediaEdits,
    required this.metadataEditable,
    required this.contentTitle,
    required this.contentDurationSeconds,
    required this.onAdd,
    required this.onRemove,
    required this.onMediaTitleChanged,
    required this.onMediaDurationChanged,
    required this.onRemovePending,
    required this.onPendingTitleChanged,
    required this.onPendingDurationChanged,
  });

  final List<AppContentMedia> items;
  final List<PendingContentMediaUpload> pendingItems;
  final Map<String, ContentMediaMetadataEdit> mediaEdits;
  final bool metadataEditable;
  final String contentTitle;
  final int? contentDurationSeconds;
  final VoidCallback? onAdd;
  final ValueChanged<AppContentMedia>? onRemove;
  final void Function(AppContentMedia item, String title)? onMediaTitleChanged;
  final void Function(AppContentMedia item, String minutesText)?
  onMediaDurationChanged;
  final ValueChanged<PendingContentMediaUpload>? onRemovePending;
  final void Function(PendingContentMediaUpload item, String title)?
  onPendingTitleChanged;
  final void Function(PendingContentMediaUpload item, String minutesText)?
  onPendingDurationChanged;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      for (final item in items)
        _MediaRow(
          key: ValueKey(item.uuidContentMedia),
          item: item,
          edit: mediaEdits[item.uuidContentMedia],
          metadataEditable: metadataEditable,
          contentTitle: contentTitle,
          contentDurationSeconds: contentDurationSeconds,
          onRemove: onRemove,
          onTitleChanged: onMediaTitleChanged == null
              ? null
              : (title) => onMediaTitleChanged!(item, title),
          onDurationChanged: onMediaDurationChanged == null
              ? null
              : (minutesText) => onMediaDurationChanged!(item, minutesText),
        ),
      for (final item in pendingItems)
        _PendingMediaRow(
          key: ValueKey(item.uuidContentMedia),
          item: item,
          metadataEditable: metadataEditable,
          contentTitle: contentTitle,
          contentDurationSeconds: contentDurationSeconds,
          onRemove: onRemovePending,
          onTitleChanged: onPendingTitleChanged == null
              ? null
              : (title) => onPendingTitleChanged!(item, title),
          onDurationChanged: onPendingDurationChanged == null
              ? null
              : (minutesText) => onPendingDurationChanged!(item, minutesText),
        ),
    ];

    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Archivos del contenido',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Agrega video, audio o sonido ambiental para poder publicar.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (rows.isEmpty)
            _EmptyMediaMessage(onAdd: onAdd)
          else
            Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  rows[index],
                  if (index < rows.length - 1)
                    const Divider(height: AppSpacing.lg),
                ],
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          AppSecondaryButton(
            label: 'Agregar archivo',
            icon: Icons.upload_file_rounded,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _EmptyMediaMessage extends StatelessWidget {
  const _EmptyMediaMessage({required this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final background = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;

    return AppInteractive(
      tooltip: 'Agregar archivo',
      borderRadius: AppRadius.medium,
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          children: [
            Icon(
              Icons.perm_media_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aún no hay archivos para este contenido.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingMediaRow extends StatefulWidget {
  const _PendingMediaRow({
    super.key,
    required this.item,
    required this.metadataEditable,
    required this.contentTitle,
    required this.contentDurationSeconds,
    required this.onRemove,
    required this.onTitleChanged,
    required this.onDurationChanged,
  });

  final PendingContentMediaUpload item;
  final bool metadataEditable;
  final String contentTitle;
  final int? contentDurationSeconds;
  final ValueChanged<PendingContentMediaUpload>? onRemove;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onDurationChanged;

  @override
  State<_PendingMediaRow> createState() => _PendingMediaRowState();
}

class _PendingMediaRowState extends State<_PendingMediaRow> {
  late final TextEditingController _titleController;
  late final TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.titulo);
    _durationController = TextEditingController(
      text: contentMediaDurationSecondsToMinutesText(
        widget.item.duracionSegundos,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _PendingMediaRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.uuidContentMedia != widget.item.uuidContentMedia) {
      _durationController.text = contentMediaDurationSecondsToMinutesText(
        widget.item.duracionSegundos,
      );
      _durationController.selection = TextSelection.collapsed(
        offset: _durationController.text.length,
      );
    }
    if (widget.item.titulo != _titleController.text) {
      _titleController.text = widget.item.titulo;
      _titleController.selection = TextSelection.collapsed(
        offset: _titleController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _mediaTypeIcon(widget.item.tipo),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.metadataEditable) ...[
                TextField(
                  controller: _titleController,
                  enabled: widget.onTitleChanged != null,
                  onChanged: widget.onTitleChanged,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: const InputDecoration(
                    hintText: 'Título del archivo',
                    isDense: true,
                    contentPadding: _mediaEditableTextPadding,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: TextField(
                    controller: _durationController,
                    enabled: widget.onDurationChanged != null,
                    onChanged: widget.onDurationChanged,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'Duración (min)',
                      isDense: true,
                      contentPadding: _mediaEditableTextPadding,
                    ),
                  ),
                ),
              ] else
                Text(
                  _readOnlyMediaTitle(widget.contentTitle, widget.item.tipo),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 4),
              Text(
                '${_mediaTypeLabel(widget.item.tipo)} · ${_formatMediaDuration(widget.metadataEditable ? widget.item.duracionSegundos : widget.contentDurationSeconds)} · Pendiente de guardar · Orden ${widget.item.orden}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Quitar archivo pendiente',
          onPressed: widget.onRemove == null
              ? null
              : () => widget.onRemove!(widget.item),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}

class _MediaRow extends StatefulWidget {
  const _MediaRow({
    super.key,
    required this.item,
    required this.edit,
    required this.metadataEditable,
    required this.contentTitle,
    required this.contentDurationSeconds,
    required this.onRemove,
    required this.onTitleChanged,
    required this.onDurationChanged,
  });

  final AppContentMedia item;
  final ContentMediaMetadataEdit? edit;
  final bool metadataEditable;
  final String contentTitle;
  final int? contentDurationSeconds;
  final ValueChanged<AppContentMedia>? onRemove;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onDurationChanged;

  @override
  State<_MediaRow> createState() => _MediaRowState();
}

class _MediaRowState extends State<_MediaRow> {
  late final TextEditingController _titleController;
  late final TextEditingController _durationController;

  String get _effectiveTitle => widget.edit?.titulo ?? widget.item.titulo ?? '';

  int? get _effectiveDurationSeconds =>
      widget.edit?.duracionSegundos ?? widget.item.duracionSegundos;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _effectiveTitle);
    _durationController = TextEditingController(
      text: contentMediaDurationSecondsToMinutesText(_effectiveDurationSeconds),
    );
  }

  @override
  void didUpdateWidget(covariant _MediaRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final mediaChanged =
        oldWidget.item.uuidContentMedia != widget.item.uuidContentMedia;
    final shouldSyncDuration =
        mediaChanged ||
        (widget.edit == null &&
            oldWidget.item.duracionSegundos != widget.item.duracionSegundos);

    if (mediaChanged) {
      _titleController.text = _effectiveTitle;
      _titleController.selection = TextSelection.collapsed(
        offset: _titleController.text.length,
      );
    } else if (_effectiveTitle != _titleController.text) {
      _titleController.text = _effectiveTitle;
      _titleController.selection = TextSelection.collapsed(
        offset: _titleController.text.length,
      );
    }

    if (shouldSyncDuration) {
      _durationController.text = contentMediaDurationSecondsToMinutesText(
        _effectiveDurationSeconds,
      );
      _durationController.selection = TextSelection.collapsed(
        offset: _durationController.text.length,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _mediaTypeIcon(widget.item.tipo),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.metadataEditable) ...[
                TextField(
                  controller: _titleController,
                  enabled: widget.onTitleChanged != null,
                  onChanged: widget.onTitleChanged,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: const InputDecoration(
                    hintText: 'Título del archivo',
                    isDense: true,
                    contentPadding: _mediaEditableTextPadding,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: TextField(
                    controller: _durationController,
                    enabled: widget.onDurationChanged != null,
                    onChanged: widget.onDurationChanged,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'Duración (min)',
                      isDense: true,
                      contentPadding: _mediaEditableTextPadding,
                    ),
                  ),
                ),
              ] else
                Text(
                  _readOnlyMediaTitle(widget.contentTitle, widget.item.tipo),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 4),
              Text(
                '${_mediaTypeLabel(widget.item.tipo)} · ${_formatMediaDuration(widget.metadataEditable ? _effectiveDurationSeconds : widget.contentDurationSeconds)} · Orden ${widget.item.orden}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (widget.item.hasPendingSync) ...[
                const SizedBox(height: 4),
                Text(
                  'Pendiente de sincronizar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: 'Quitar archivo',
          onPressed: widget.onRemove == null
              ? null
              : () => widget.onRemove!(widget.item),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
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

const _contentTypes = ['meditation', 'audio', 'sound', 'event'];

String _contentTypeForForm(String tipo) {
  final cleanType = tipo.trim().toLowerCase();
  return _contentTypes.contains(cleanType) ? cleanType : 'meditation';
}

const _mediaEditableTextPadding = EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 10,
);

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

IconData _mediaTypeIcon(String tipo) {
  final cleanType = tipo.trim().toLowerCase();
  if (ContentMediaFileMetadata.isVideoType(cleanType)) {
    return Icons.videocam_outlined;
  }

  return switch (cleanType) {
    'video' => Icons.videocam_outlined,
    'ambient_sound' => Icons.graphic_eq_rounded,
    _ => Icons.mic_none_rounded,
  };
}

String _mediaTypeLabel(String tipo) {
  final cleanType = tipo.trim().toLowerCase();
  if (ContentMediaFileMetadata.isSupportedType(cleanType)) {
    return cleanType.toUpperCase();
  }

  return switch (cleanType) {
    'video' => 'Video',
    'audio' => 'Audio',
    'ambient_sound' => 'Sonido ambiental',
    _ => tipo,
  };
}

String _readOnlyMediaTitle(String contentTitle, String mediaType) {
  final cleanTitle = contentTitle.trim();
  if (cleanTitle.isNotEmpty) {
    return cleanTitle;
  }

  return _mediaTypeLabel(mediaType);
}

String _formatMediaDuration(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return 'Duración pendiente';
  }

  final totalMinutes = (seconds / 60).round();
  if (totalMinutes < 60) {
    return '$totalMinutes min';
  }

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
}

String _generateUuidV4() {
  final random = math.Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String byteToHex(int value) => value.toRadixString(16).padLeft(2, '0');
  final hex = bytes.map(byteToHex).join();
  return [
    hex.substring(0, 8),
    hex.substring(8, 12),
    hex.substring(12, 16),
    hex.substring(16, 20),
    hex.substring(20),
  ].join('-');
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
