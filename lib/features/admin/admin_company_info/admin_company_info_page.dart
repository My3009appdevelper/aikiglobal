import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/data/models/app_company_info.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/company_info_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_saving_overlay.dart';
import '../../../shared/widgets/app_text_field.dart';

class AdminCompanyInfoPage extends StatefulWidget {
  const AdminCompanyInfoPage({super.key});

  @override
  State<AdminCompanyInfoPage> createState() => _AdminCompanyInfoPageState();
}

class _AdminCompanyInfoPageState extends State<AdminCompanyInfoPage> {
  final _textoEntradaController = TextEditingController();
  final _quienesSomosController = TextEditingController();
  final _significadoAikiController = TextEditingController();
  final _misionController = TextEditingController();
  final _visionController = TextEditingController();
  final _filosofiaController = TextEditingController();

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
    unawaited(nextController.pullFromRemote());
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChanged);
    _removeFieldListeners();
    _textoEntradaController.dispose();
    _quienesSomosController.dispose();
    _significadoAikiController.dispose();
    _misionController.dispose();
    _visionController.dispose();
    _filosofiaController.dispose();
    super.dispose();
  }

  void _addFieldListeners() {
    _textoEntradaController.addListener(_handleFieldChanged);
    _quienesSomosController.addListener(_handleFieldChanged);
    _significadoAikiController.addListener(_handleFieldChanged);
    _misionController.addListener(_handleFieldChanged);
    _visionController.addListener(_handleFieldChanged);
    _filosofiaController.addListener(_handleFieldChanged);
  }

  void _removeFieldListeners() {
    _textoEntradaController.removeListener(_handleFieldChanged);
    _quienesSomosController.removeListener(_handleFieldChanged);
    _significadoAikiController.removeListener(_handleFieldChanged);
    _misionController.removeListener(_handleFieldChanged);
    _visionController.removeListener(_handleFieldChanged);
    _filosofiaController.removeListener(_handleFieldChanged);
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
    _textoEntradaController.text = info.textoEntrada;
    _quienesSomosController.text = info.quienesSomos;
    _significadoAikiController.text = info.significadoAiki;
    _misionController.text = info.mision;
    _visionController.text = info.vision;
    _filosofiaController.text = info.filosofia;
    _initialSnapshot = _currentSnapshot();
    _loadedInitialInfo = true;
    _addFieldListeners();

    if (mounted) {
      setState(() {});
    }
  }

  _CompanyInfoFormSnapshot _currentSnapshot() {
    return _CompanyInfoFormSnapshot(
      textoEntrada: _textoEntradaController.text.trim(),
      quienesSomos: _quienesSomosController.text.trim(),
      significadoAiki: _significadoAikiController.text.trim(),
      mision: _misionController.text.trim(),
      vision: _visionController.text.trim(),
      filosofia: _filosofiaController.text.trim(),
    );
  }

  Future<void> _refresh() async {
    await AppDataScope.companyInfo(context).syncWithRemote();
  }

  Future<void> _save() async {
    final controller = AppDataScope.companyInfo(context);

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await controller.saveInfo(
        textoEntrada: _textoEntradaController.text,
        quienesSomos: _quienesSomosController.text,
        significadoAiki: _significadoAikiController.text,
        mision: _misionController.text,
        vision: _visionController.text,
        filosofia: _filosofiaController.text,
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
                        _AdminCompanyInfoHeader(
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
                        _AdminCompanyInfoCard(
                          child: Column(
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
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppPrimaryButton(
                          label: 'Guardar cambios',
                          icon: Icons.check_rounded,
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

class _AdminCompanyInfoHeader extends StatelessWidget {
  const _AdminCompanyInfoHeader({
    required this.isLoading,
    required this.isSyncing,
    required this.isPending,
  });

  final bool isLoading;
  final bool isSyncing;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.background;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Información de la empresa',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (isLoading || isSyncing)
                const _SmallBadge(label: 'Sincronizando')
              else if (isPending)
                const _SmallBadge(label: 'Pendiente'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Edita texto de entrada, significado, misión, visión y filosofía.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AdminCompanyInfoCard extends StatelessWidget {
  const _AdminCompanyInfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.background;
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

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final background = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.full,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CompanyInfoFormSnapshot {
  const _CompanyInfoFormSnapshot({
    required this.textoEntrada,
    required this.quienesSomos,
    required this.significadoAiki,
    required this.mision,
    required this.vision,
    required this.filosofia,
  });

  final String textoEntrada;
  final String quienesSomos;
  final String significadoAiki;
  final String mision;
  final String vision;
  final String filosofia;

  @override
  bool operator ==(Object other) {
    return other is _CompanyInfoFormSnapshot &&
        other.textoEntrada == textoEntrada &&
        other.quienesSomos == quienesSomos &&
        other.significadoAiki == significadoAiki &&
        other.mision == mision &&
        other.vision == vision &&
        other.filosofia == filosofia;
  }

  @override
  int get hashCode => Object.hash(
    textoEntrada,
    quienesSomos,
    significadoAiki,
    mision,
    vision,
    filosofia,
  );
}
