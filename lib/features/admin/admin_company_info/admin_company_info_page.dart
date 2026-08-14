import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/data/models/app_company_info.dart';
import '../../../core/data/models/pending_company_info_image_upload.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/app_load_coordinator.dart';
import '../../../core/data/providers/company_info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_saving_overlay.dart';
import '../../../shared/widgets/app_segmented_tabs.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_cover_image.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/my_image_picker.dart';

class AdminCompanyInfoPage extends StatefulWidget {
  const AdminCompanyInfoPage({super.key});

  @override
  State<AdminCompanyInfoPage> createState() => _AdminCompanyInfoPageState();
}

class _AdminCompanyInfoPageState extends State<AdminCompanyInfoPage> {
  final _heroTituloController = TextEditingController();
  final _heroSubtituloController = TextEditingController();
  final _textoEntradaController = TextEditingController();
  final _quienesSomosController = TextEditingController();
  final _significadoAikiController = TextEditingController();
  final _misionController = TextEditingController();
  final _visionController = TextEditingController();
  final _filosofiaController = TextEditingController();
  final _mensajeFundadoresTituloController = TextEditingController();
  final _mensajeFundadoresTextoController = TextEditingController();
  final _heroImageDraft = _CompanyInfoImageDraft();
  final _fundadoresImageDrafts = List<_CompanyInfoImageDraft>.generate(
    5,
    (_) => _CompanyInfoImageDraft(),
  );

  CompanyInfoController? _controller;
  late _CompanyInfoFormSnapshot _initialSnapshot;
  bool _initialized = false;
  bool _loadedInitialInfo = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _hasChanges => _currentSnapshot() != _initialSnapshot;

  @override
  void initState() {
    super.initState();
    _initialSnapshot = _currentSnapshot();
    _addFieldListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final nextController = AppDataScope.companyInfo(context);
    if (_controller != nextController) {
      _controller?.removeListener(_handleControllerChanged);
      _controller = nextController..addListener(_handleControllerChanged);
    }

    if (_initialized) {
      return;
    }

    _initialized = true;
    nextController.watch();
    unawaited(
      AppDataScope.loadCoordinator(
        context,
      ).syncWithRemote(scope: AppLoadScope.adminCompany),
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChanged);
    _removeFieldListeners();
    _heroTituloController.dispose();
    _heroSubtituloController.dispose();
    _textoEntradaController.dispose();
    _quienesSomosController.dispose();
    _significadoAikiController.dispose();
    _misionController.dispose();
    _visionController.dispose();
    _filosofiaController.dispose();
    _mensajeFundadoresTituloController.dispose();
    _mensajeFundadoresTextoController.dispose();
    super.dispose();
  }

  void _addFieldListeners() {
    _heroTituloController.addListener(_handleFieldChanged);
    _heroSubtituloController.addListener(_handleFieldChanged);
    _textoEntradaController.addListener(_handleFieldChanged);
    _quienesSomosController.addListener(_handleFieldChanged);
    _significadoAikiController.addListener(_handleFieldChanged);
    _misionController.addListener(_handleFieldChanged);
    _visionController.addListener(_handleFieldChanged);
    _filosofiaController.addListener(_handleFieldChanged);
    _mensajeFundadoresTituloController.addListener(_handleFieldChanged);
    _mensajeFundadoresTextoController.addListener(_handleFieldChanged);
  }

  void _removeFieldListeners() {
    _heroTituloController.removeListener(_handleFieldChanged);
    _heroSubtituloController.removeListener(_handleFieldChanged);
    _textoEntradaController.removeListener(_handleFieldChanged);
    _quienesSomosController.removeListener(_handleFieldChanged);
    _significadoAikiController.removeListener(_handleFieldChanged);
    _misionController.removeListener(_handleFieldChanged);
    _visionController.removeListener(_handleFieldChanged);
    _filosofiaController.removeListener(_handleFieldChanged);
    _mensajeFundadoresTituloController.removeListener(_handleFieldChanged);
    _mensajeFundadoresTextoController.removeListener(_handleFieldChanged);
  }

  void _handleFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleControllerChanged() {
    final controller = _controller;
    if (controller == null || !mounted) {
      return;
    }

    if (!_loadedInitialInfo || !_hasChanges) {
      _replaceFormValues(controller.item);
      return;
    }

    setState(() {});
  }

  void _replaceFormValues(AppCompanyInfo info) {
    _removeFieldListeners();
    _heroTituloController.text = info.heroTitulo;
    _heroSubtituloController.text = info.heroSubtitulo;
    _textoEntradaController.text = info.textoEntrada;
    _quienesSomosController.text = info.quienesSomos;
    _significadoAikiController.text = info.significadoAiki;
    _misionController.text = info.mision;
    _visionController.text = info.vision;
    _filosofiaController.text = info.filosofia;
    _mensajeFundadoresTituloController.text = info.mensajeFundadoresTitulo;
    _mensajeFundadoresTextoController.text = info.mensajeFundadoresTexto;
    _heroImageDraft.setRemotePath(info.heroImagePath);
    _fundadoresImageDrafts[0].setRemotePath(info.mensajeFundadoresImagePath1);
    _fundadoresImageDrafts[1].setRemotePath(info.mensajeFundadoresImagePath2);
    _fundadoresImageDrafts[2].setRemotePath(info.mensajeFundadoresImagePath3);
    _fundadoresImageDrafts[3].setRemotePath(info.mensajeFundadoresImagePath4);
    _fundadoresImageDrafts[4].setRemotePath(info.mensajeFundadoresImagePath5);
    _initialSnapshot = _currentSnapshot();
    _loadedInitialInfo = true;
    _addFieldListeners();

    if (mounted) {
      setState(() {});
    }
  }

  _CompanyInfoFormSnapshot _currentSnapshot() {
    return _CompanyInfoFormSnapshot(
      heroTitulo: _heroTituloController.text.trim(),
      heroSubtitulo: _heroSubtituloController.text.trim(),
      heroImage: _heroImageDraft.snapshot(),
      textoEntrada: _textoEntradaController.text.trim(),
      quienesSomos: _quienesSomosController.text.trim(),
      significadoAiki: _significadoAikiController.text.trim(),
      mision: _misionController.text.trim(),
      vision: _visionController.text.trim(),
      filosofia: _filosofiaController.text.trim(),
      mensajeFundadoresTitulo: _mensajeFundadoresTituloController.text.trim(),
      mensajeFundadoresTexto: _mensajeFundadoresTextoController.text.trim(),
      fundadoresImage1: _fundadoresImageDrafts[0].snapshot(),
      fundadoresImage2: _fundadoresImageDrafts[1].snapshot(),
      fundadoresImage3: _fundadoresImageDrafts[2].snapshot(),
      fundadoresImage4: _fundadoresImageDrafts[3].snapshot(),
      fundadoresImage5: _fundadoresImageDrafts[4].snapshot(),
    );
  }

  Future<void> _pickCompanyImage({
    required _CompanyInfoImageDraft draft,
    required String title,
  }) async {
    final pickedImage = await MyImagePicker.pick(
      context,
      title: title,
      onRemovePhoto: () async {
        if (!mounted) {
          return;
        }

        setState(() {
          draft.clear();
          _errorMessage = null;
        });
      },
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
      draft.setPending(
        bytes: bytes,
        fileName: pickedImage.name,
        contentType: pickedImage.mimeType,
      );
      _errorMessage = null;
    });
  }

  Future<void> _refresh() async {
    await AppDataScope.loadCoordinator(
      context,
    ).syncWithRemote(scope: AppLoadScope.adminCompany);
  }

  Future<void> _save() async {
    final controller = AppDataScope.companyInfo(context);

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await controller.saveInfo(
        heroTitulo: _heroTituloController.text,
        heroSubtitulo: _heroSubtituloController.text,
        heroImagePath: _heroImageDraft.imagePathForSave,
        heroImageUpload: _heroImageDraft.pendingUpload,
        textoEntrada: _textoEntradaController.text,
        quienesSomos: _quienesSomosController.text,
        significadoAiki: _significadoAikiController.text,
        mision: _misionController.text,
        vision: _visionController.text,
        filosofia: _filosofiaController.text,
        mensajeFundadoresTitulo: _mensajeFundadoresTituloController.text,
        mensajeFundadoresTexto: _mensajeFundadoresTextoController.text,
        mensajeFundadoresImagePath1: _fundadoresImageDrafts[0].imagePathForSave,
        mensajeFundadoresImageUpload1: _fundadoresImageDrafts[0].pendingUpload,
        mensajeFundadoresImagePath2: _fundadoresImageDrafts[1].imagePathForSave,
        mensajeFundadoresImageUpload2: _fundadoresImageDrafts[1].pendingUpload,
        mensajeFundadoresImagePath3: _fundadoresImageDrafts[2].imagePathForSave,
        mensajeFundadoresImageUpload3: _fundadoresImageDrafts[2].pendingUpload,
        mensajeFundadoresImagePath4: _fundadoresImageDrafts[3].imagePathForSave,
        mensajeFundadoresImageUpload4: _fundadoresImageDrafts[3].pendingUpload,
        mensajeFundadoresImagePath5: _fundadoresImageDrafts[4].imagePathForSave,
        mensajeFundadoresImageUpload5: _fundadoresImageDrafts[4].pendingUpload,
        syncAfterSave: true,
      );
      _replaceFormValues(controller.item);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Información de la empresa guardada.'),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error is ArgumentError
            ? error.message.toString()
            : 'No se pudo guardar la información. Revisa tus permisos o conexión.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildHeroFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _heroTituloController,
          labelText: 'Título del hero',
          hintText: 'Título del hero',
          prefixIcon: Icons.title_rounded,
          minLines: 1,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _heroSubtituloController,
          labelText: 'Subtítulo del hero',
          hintText: 'Subtítulo del hero',
          prefixIcon: Icons.short_text_rounded,
          minLines: 2,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.md),
        _CompanyInfoImagePickerCard(
          label: 'Imagen del hero',
          imagePath: _heroImageDraft.selectedImagePath,
          previewBytes: _heroImageDraft.previewBytes,
          height: 190,
          onTap: () => _pickCompanyImage(
            draft: _heroImageDraft,
            title: 'Imagen del hero',
          ),
        ),
      ],
    );
  }

  Widget _buildFounderFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _mensajeFundadoresTituloController,
          labelText: 'Título del mensaje',
          hintText: 'Título del mensaje',
          prefixIcon: Icons.format_quote_rounded,
          minLines: 1,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _mensajeFundadoresTextoController,
          labelText: 'Texto del mensaje',
          hintText: 'Texto del mensaje',
          prefixIcon: Icons.notes_rounded,
          minLines: 5,
          maxLines: 10,
        ),
        const SizedBox(height: AppSpacing.md),
        _FounderImagesEditor(
          drafts: _fundadoresImageDrafts,
          onPick: (index) => _pickCompanyImage(
            draft: _fundadoresImageDrafts[index],
            title: 'Imagen fundadores ${index + 1}',
          ),
        ),
      ],
    );
  }

  Widget _buildAikiFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _textoEntradaController,
          labelText: 'Texto de entrada',
          hintText: 'Texto de entrada',
          prefixIcon: Icons.waving_hand_outlined,
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _quienesSomosController,
          labelText: 'Quiénes somos',
          hintText: 'Quiénes somos',
          prefixIcon: Icons.groups_2_outlined,
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _significadoAikiController,
          labelText: 'Significado de Aiki',
          hintText: 'Significado de Aiki',
          prefixIcon: Icons.self_improvement_outlined,
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _misionController,
          labelText: 'Misión',
          hintText: 'Misión',
          prefixIcon: Icons.auto_awesome_outlined,
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _visionController,
          labelText: 'Visión',
          hintText: 'Visión',
          prefixIcon: Icons.visibility_outlined,
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _filosofiaController,
          labelText: 'Filosofía',
          hintText: 'Filosofía',
          prefixIcon: Icons.spa_outlined,
          minLines: 3,
          maxLines: 7,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppDataScope.companyInfo(context);
    final info = controller.item;

    return SafeArea(
      bottom: false,
      child: AppSavingOverlay(
        isSaving: _isSaving,
        message: 'Guardando información...',
        detail: 'Actualizando los datos visibles para los usuarios.',
        child: AppResponsiveContainer(
          child: AppRefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppLogo(width: 148),
                        const SizedBox(height: AppSpacing.lg),
                        AdminCompanyInfoHeader(
                          isLoading: controller.isLoading,
                          isSyncing: controller.isSyncing,
                          isPending: info.hasPendingSync,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          _AdminCompanyInfoMessage(
                            icon: Icons.warning_amber_rounded,
                            title: 'No se pudo guardar',
                            body: _errorMessage!,
                          ),
                        ] else if (controller.error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          const _AdminCompanyInfoMessage(
                            icon: Icons.cloud_off_outlined,
                            title: 'No se pudo sincronizar',
                            body:
                                'Revisa tu conexión o permisos de administrador.',
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AdminCompanyInfoTabbedCard(
                          hero: _buildHeroFields(),
                          fundadores: _buildFounderFields(),
                          aiki: _buildAikiFields(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AdminCompanyInfoSaveButton(
                          onPressed: _isSaving || !_hasChanges ? null : _save,
                        ),
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
}

class AdminCompanyInfoHeader extends StatelessWidget {
  const AdminCompanyInfoHeader({
    super.key,
    required this.isLoading,
    required this.isSyncing,
    required this.isPending,
  });

  // Conserved in the public widget contract for existing callers. Status is
  // intentionally not rendered beside the title anymore.
  final bool isLoading;
  final bool isSyncing;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de la empresa',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: scheme.onSurface,
              fontFamily: AppTypography.displayFont,
              fontFamilyFallback: AppTypography.fallbackFonts,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Edita texto de entrada, significado, misión, visión y filosofía.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontFamily: AppTypography.primaryFont,
              fontFamilyFallback: AppTypography.fallbackFonts,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminCompanyInfoCard extends StatelessWidget {
  const AdminCompanyInfoCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: child,
    );
  }
}

class AdminCompanyInfoSaveButton extends StatelessWidget {
  const AdminCompanyInfoSaveButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: 'Guardar cambios',
      icon: Icons.check_rounded,
      onPressed: onPressed,
      labelStyle: const TextStyle(
        fontFamily: AppTypography.displayFont,
        fontFamilyFallback: AppTypography.fallbackFonts,
      ),
    );
  }
}

class AdminCompanyInfoTabbedCard extends StatefulWidget {
  const AdminCompanyInfoTabbedCard({
    super.key,
    required this.hero,
    required this.fundadores,
    required this.aiki,
  });

  final Widget hero;
  final Widget fundadores;
  final Widget aiki;

  @override
  State<AdminCompanyInfoTabbedCard> createState() =>
      _AdminCompanyInfoTabbedCardState();
}

class _AdminCompanyInfoTabbedCardState
    extends State<AdminCompanyInfoTabbedCard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AdminCompanyInfoTabs(
          selectedIndex: _selectedIndex,
          onChanged: (index) {
            if (_selectedIndex == index) {
              return;
            }
            setState(() => _selectedIndex = index);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AdminCompanyInfoCard(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: switch (_selectedIndex) {
                0 => widget.hero,
                1 => widget.fundadores,
                _ => widget.aiki,
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminCompanyInfoTabs extends StatelessWidget {
  const _AdminCompanyInfoTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSegmentedTabs(
      labels: const ['Hero', 'Fundadores', 'Aiki'],
      selectedIndex: selectedIndex,
      onChanged: onChanged,
    );
  }
}

class _FounderImagesEditor extends StatelessWidget {
  const _FounderImagesEditor({required this.drafts, required this.onPick});

  final List<_CompanyInfoImageDraft> drafts;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        final tileWidth = isWide
            ? (constraints.maxWidth - AppSpacing.md) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (var index = 0; index < drafts.length; index++)
              SizedBox(
                width: tileWidth,
                child: _CompanyInfoImagePickerCard(
                  label: 'Imagen ${index + 1}',
                  imagePath: drafts[index].selectedImagePath,
                  previewBytes: drafts[index].previewBytes,
                  height: 136,
                  onTap: () => onPick(index),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CompanyInfoImagePickerCard extends StatelessWidget {
  const _CompanyInfoImagePickerCard({
    required this.label,
    required this.onTap,
    this.imagePath,
    this.previewBytes,
    this.height = 160,
  });

  final String label;
  final String? imagePath;
  final Uint8List? previewBytes;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.background;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final hasImage =
        previewBytes != null || (imagePath != null && imagePath!.isNotEmpty);

    return AppInteractive(
      tooltip: label,
      borderRadius: AppRadius.large,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.92),
          borderRadius: AppRadius.large,
          border: Border.all(color: stroke),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (previewBytes != null)
              Image.memory(previewBytes!, fit: BoxFit.cover)
            else if (imagePath != null && imagePath!.isNotEmpty)
              AppCoverImage(
                imagePath: imagePath,
                resolveImageUrl: AppDataScope.companyInfo(
                  context,
                ).resolveInfoImageUrl,
                fallback: _imageFallback(context),
              )
            else
              _imageFallback(context),
            if (hasImage)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.02),
                      AppColors.black.withValues(alpha: 0.42),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      hasImage ? 'Cambiar $label' : label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: hasImage
                            ? AppColors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
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

  Widget _imageFallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: 36,
      ),
    );
  }
}

class _AdminCompanyInfoMessage extends StatelessWidget {
  const _AdminCompanyInfoMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.background;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyInfoImageDraft {
  String? remotePath;
  Uint8List? previewBytes;
  String? fileName;
  String? contentType;

  String? get selectedImagePath {
    final path = remotePath?.trim();
    if (path == null || path.isEmpty) {
      return null;
    }
    return path;
  }

  String? get imagePathForSave => selectedImagePath;

  PendingCompanyInfoImageUpload? get pendingUpload {
    final bytes = previewBytes;
    final cleanFileName = fileName?.trim();
    if (bytes == null || bytes.isEmpty || cleanFileName == null) {
      return null;
    }

    return PendingCompanyInfoImageUpload(
      bytes: bytes,
      fileName: cleanFileName.isEmpty ? 'imagen.jpg' : cleanFileName,
      contentType: contentType,
    );
  }

  void setRemotePath(String? path) {
    remotePath = path?.trim();
    previewBytes = null;
    fileName = null;
    contentType = null;
  }

  void setPending({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) {
    remotePath = null;
    previewBytes = bytes;
    this.fileName = fileName;
    this.contentType = contentType;
  }

  void clear() {
    remotePath = null;
    previewBytes = null;
    fileName = null;
    contentType = null;
  }

  _CompanyInfoImageSnapshot snapshot() {
    return _CompanyInfoImageSnapshot(
      remotePath: selectedImagePath ?? '',
      hasPendingUpload: previewBytes != null,
      pendingFileName: fileName?.trim() ?? '',
    );
  }
}

class _CompanyInfoImageSnapshot {
  const _CompanyInfoImageSnapshot({
    required this.remotePath,
    required this.hasPendingUpload,
    required this.pendingFileName,
  });

  final String remotePath;
  final bool hasPendingUpload;
  final String pendingFileName;

  @override
  bool operator ==(Object other) {
    return other is _CompanyInfoImageSnapshot &&
        other.remotePath == remotePath &&
        other.hasPendingUpload == hasPendingUpload &&
        other.pendingFileName == pendingFileName;
  }

  @override
  int get hashCode =>
      Object.hash(remotePath, hasPendingUpload, pendingFileName);
}

class _CompanyInfoFormSnapshot {
  const _CompanyInfoFormSnapshot({
    required this.heroTitulo,
    required this.heroSubtitulo,
    required this.heroImage,
    required this.textoEntrada,
    required this.quienesSomos,
    required this.significadoAiki,
    required this.mision,
    required this.vision,
    required this.filosofia,
    required this.mensajeFundadoresTitulo,
    required this.mensajeFundadoresTexto,
    required this.fundadoresImage1,
    required this.fundadoresImage2,
    required this.fundadoresImage3,
    required this.fundadoresImage4,
    required this.fundadoresImage5,
  });

  final String heroTitulo;
  final String heroSubtitulo;
  final _CompanyInfoImageSnapshot heroImage;
  final String textoEntrada;
  final String quienesSomos;
  final String significadoAiki;
  final String mision;
  final String vision;
  final String filosofia;
  final String mensajeFundadoresTitulo;
  final String mensajeFundadoresTexto;
  final _CompanyInfoImageSnapshot fundadoresImage1;
  final _CompanyInfoImageSnapshot fundadoresImage2;
  final _CompanyInfoImageSnapshot fundadoresImage3;
  final _CompanyInfoImageSnapshot fundadoresImage4;
  final _CompanyInfoImageSnapshot fundadoresImage5;

  @override
  bool operator ==(Object other) {
    return other is _CompanyInfoFormSnapshot &&
        other.heroTitulo == heroTitulo &&
        other.heroSubtitulo == heroSubtitulo &&
        other.heroImage == heroImage &&
        other.textoEntrada == textoEntrada &&
        other.quienesSomos == quienesSomos &&
        other.significadoAiki == significadoAiki &&
        other.mision == mision &&
        other.vision == vision &&
        other.filosofia == filosofia &&
        other.mensajeFundadoresTitulo == mensajeFundadoresTitulo &&
        other.mensajeFundadoresTexto == mensajeFundadoresTexto &&
        other.fundadoresImage1 == fundadoresImage1 &&
        other.fundadoresImage2 == fundadoresImage2 &&
        other.fundadoresImage3 == fundadoresImage3 &&
        other.fundadoresImage4 == fundadoresImage4 &&
        other.fundadoresImage5 == fundadoresImage5;
  }

  @override
  int get hashCode => Object.hash(
    heroTitulo,
    heroSubtitulo,
    heroImage,
    textoEntrada,
    quienesSomos,
    significadoAiki,
    mision,
    vision,
    filosofia,
    mensajeFundadoresTitulo,
    mensajeFundadoresTexto,
    fundadoresImage1,
    fundadoresImage2,
    fundadoresImage3,
    fundadoresImage4,
    fundadoresImage5,
  );
}
