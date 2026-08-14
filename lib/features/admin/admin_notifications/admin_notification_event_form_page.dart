import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/data/common/json_object_codec.dart';
import '../../../core/data/models/app_content_item.dart';
import '../../../core/data/models/app_notification_event.dart';
import '../../../core/data/models/manual_notification_dispatch_result.dart';
import '../../../core/data/models/notification_values.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/app_load_coordinator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_saving_overlay.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'notification_admin_labels.dart';
import 'notification_preview_card.dart';
import 'notification_template_editor.dart';

const _notificationBegumTextStyle = TextStyle(
  fontFamily: AppTypography.displayFont,
  fontFamilyFallback: AppTypography.fallbackFonts,
  fontWeight: FontWeight.w600,
);

class AdminNotificationEventFormPage extends StatefulWidget {
  const AdminNotificationEventFormPage({
    super.key,
    this.event,
    this.duplicate = false,
  });

  final AppNotificationEvent? event;
  final bool duplicate;

  @override
  State<AdminNotificationEventFormPage> createState() =>
      _AdminNotificationEventFormPageState();
}

class _AdminNotificationEventFormPageState
    extends State<AdminNotificationEventFormPage> {
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _category = 'general';
  String _audience = 'all';
  String _action = 'none';
  String _triggerType = 'manual';
  String? _triggerKey;
  String _executionMode = 'once';
  Map<String, dynamic> _triggerConfig = const {};
  String? _contentUuid;
  String? _persistedUuid;
  String _persistedStatus = 'draft';
  late DateTime _startsAt;
  DateTime? _endsAt;
  late _NotificationFormSnapshot _initialSnapshot;
  List<AppContentItem> _publishedContent = const [];
  bool _contentLoaded = false;
  bool _dependenciesLoaded = false;
  late bool _hasBeenPersisted;
  bool _isBusy = false;
  String _busyMessage = 'Guardando cambios...';
  String? _errorMessage;

  bool get _isDuplicate =>
      widget.duplicate && widget.event != null && !_hasBeenPersisted;
  bool get _isCompleted => !_isDuplicate && _persistedStatus == 'completed';
  bool get _isAutomatic => !notificationEventAllowsManualSend(_triggerType);
  bool get _contentDestinationIsDynamic =>
      notificationContentDestinationIsDynamic(_triggerKey);
  bool get _hasChanges => _currentSnapshot() != _initialSnapshot;

  @override
  void initState() {
    super.initState();
    final source = widget.event;
    _hasBeenPersisted = source != null && !widget.duplicate;
    _startsAt = widget.duplicate
        ? DateTime.now().toUtc()
        : source?.startsAt ?? DateTime.now().toUtc();
    _endsAt = widget.duplicate ? null : source?.endsAt;
    if (source != null) {
      _nameController.text = _isDuplicate
          ? 'Copia de ${source.name}'
          : source.name;
      _titleController.text = source.titleTemplate;
      _bodyController.text = source.bodyTemplate;
      _category = source.category;
      _audience = source.audienceType;
      _action = source.actionType;
      _triggerType = source.triggerType;
      _triggerKey = source.triggerKey;
      _executionMode = source.executionMode;
      _triggerConfig = Map<String, dynamic>.from(source.triggerConfig);
      _contentUuid =
          source.actionPayloadTemplate['uuid_content_item'] as String?;
      if (!_isDuplicate) {
        _persistedUuid = source.uuidNotificationEvent;
        _persistedStatus = source.status;
      }
    }
    _initialSnapshot = _currentSnapshot();
    _nameController.addListener(_handleChanged);
    _titleController.addListener(_handleChanged);
    _bodyController.addListener(_handleChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileUuid = AppDataScope.currentProfile(
      context,
    ).profile?.uuidProfile;
    final stats = AppDataScope.wellnessProfileStats(context);
    if (profileUuid != null &&
        profileUuid.trim().isNotEmpty &&
        stats.activeProfileUuid != profileUuid) {
      stats.watchForProfile(profileUuid, pullRemote: false);
    }
    if (_dependenciesLoaded) {
      return;
    }
    _dependenciesLoaded = true;
    unawaited(
      AppDataScope.loadCoordinator(
        context,
      ).syncWithRemote(scope: AppLoadScope.adminNotifications),
    );
    unawaited(_loadPublishedContent());
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleChanged);
    _titleController.removeListener(_handleChanged);
    _bodyController.removeListener(_handleChanged);
    _nameController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _handleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _configureAutomaticMessageTemplates() {
    final triggerKey = _triggerKey;
    if (!isAutomaticMessageTriggerKey(triggerKey)) {
      return;
    }
    _titleController.text = notificationAutomaticTitleTemplate(triggerKey!);
    _bodyController.text = notificationAutomaticMessageCoreTemplate(triggerKey);
  }

  String get _previewTitle {
    final parts = parseNotificationTemplate(
      _titleController.text,
      allowedVariables: notificationAllowedTemplateVariables(_triggerKey),
    );
    return renderNotificationTemplateExample(parts, examples: _previewValues);
  }

  String get _previewBody {
    final parts = parseNotificationTemplate(
      _bodyController.text,
      allowedVariables: notificationAllowedTemplateVariables(_triggerKey),
    );
    return renderNotificationTemplateExample(parts, examples: _previewValues);
  }

  Map<String, String> get _previewValues {
    final profile = AppDataScope.currentProfile(context).profile;
    final stats = AppDataScope.wellnessProfileStats(context);
    return notificationTemplatePreviewValues(
      _triggerKey,
      profileName: profile?.nombre,
      profileEmail: profile?.email,
      overrides: isStreakAutomaticTriggerKey(_triggerKey)
          ? notificationStreakPreviewValuesForTrigger(
              triggerKey: _triggerKey,
              triggerConfig: _triggerConfig,
              currentStreak: stats.currentStreak,
              longestStreak: stats.longestStreak,
              lastActivityDate: stats.lastActivityDate,
            )
          : const {},
    );
  }

  Future<void> _loadPublishedContent() async {
    final controller = AppDataScope.contentItems(context);
    final loadCoordinator = AppDataScope.loadCoordinator(context);
    try {
      var items = await controller.getPublishedSnapshot();
      if (items.isEmpty) {
        await loadCoordinator.syncWithRemote(
          scope: AppLoadScope.adminNotifications,
        );
        items = await controller.getPublishedSnapshot();
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _publishedContent = items;
        _contentLoaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _contentLoaded = true);
      }
    }
  }

  _NotificationFormSnapshot _currentSnapshot() {
    return _NotificationFormSnapshot(
      name: _nameController.text,
      title: _titleController.text,
      body: _bodyController.text,
      category: _category,
      audience: _audience,
      action: _action,
      triggerType: _triggerType,
      triggerKey: _triggerKey,
      executionMode: _executionMode,
      triggerConfigJson: encodeJsonObject(_triggerConfig),
      startsAt: _startsAt,
      endsAt: _endsAt,
      contentUuid:
          _action == 'open_content_item' && !_contentDestinationIsDynamic
          ? _contentUuid
          : null,
    );
  }

  AppNotificationEvent? _currentPersistedEvent() {
    final uuid = _persistedUuid;
    if (uuid == null) {
      return null;
    }
    for (final event in AppDataScope.notificationEvents(context).events) {
      if (event.uuidNotificationEvent == uuid) {
        return event;
      }
    }
    return null;
  }

  bool get _canSend {
    final event = _currentPersistedEvent();
    return !_isBusy &&
        !_isAutomatic &&
        !_hasChanges &&
        _persistedStatus == 'active' &&
        event != null &&
        event.status == 'active' &&
        !event.hasPendingSync &&
        event.isActiveAt(DateTime.now().toUtc());
  }

  bool get _canSaveActive {
    return _hasChanges || (_currentPersistedEvent()?.hasPendingSync ?? false);
  }

  Future<void> _save(String status) async {
    if (_isCompleted) {
      return;
    }
    if (_action == 'open_content_item' &&
        !_contentDestinationIsDynamic &&
        _contentUuid == null) {
      setState(() => _errorMessage = 'Selecciona el contenido que se abrirá.');
      return;
    }

    final isNewRecord = !_hasBeenPersisted;
    final eventUuid = _persistedUuid ?? _generateUuidV4();
    setState(() {
      _persistedUuid = eventUuid;
      _isBusy = true;
      _busyMessage = 'Guardando notificación...';
      _errorMessage = null;
    });
    try {
      final titleTemplate = _titleController.text;
      final bodyTemplate = _bodyController.text;
      final profileUuid = AppDataScope.currentProfile(
        context,
      ).profile?.uuidProfile;
      final uuid = await AppDataScope.notificationEvents(context)
          .saveNotificationEvent(
            uuidNotificationEvent: eventUuid,
            name: _nameController.text,
            category: _category,
            titleTemplate: titleTemplate,
            bodyTemplate: bodyTemplate,
            triggerType: _triggerType,
            triggerKey: _isAutomatic ? _triggerKey : null,
            executionMode: _isAutomatic ? _executionMode : 'once',
            audienceType: _audience,
            actionType: _action,
            actionPayloadTemplate: notificationActionPayloadTemplate(
              actionType: _action,
              triggerKey: _triggerKey,
              contentUuid: _contentUuid,
            ),
            triggerConfig: _isAutomatic ? _triggerConfig : const {},
            startsAt: _startsAt,
            endsAt: _endsAt,
            status: status,
            uuidCreatedByProfile: isNewRecord ? profileUuid : null,
            uuidUpdatedByProfile: profileUuid,
            syncAfterSave: true,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _persistedUuid = uuid;
        _persistedStatus = status;
        _hasBeenPersisted = true;
        _initialSnapshot = _currentSnapshot();
      });
      _showMessage(
        status == 'active'
            ? 'La notificación quedó activa.'
            : 'El borrador se guardó correctamente.',
      );
    } catch (error) {
      if (mounted) {
        final local = _currentPersistedEvent();
        setState(() {
          if (local != null) {
            _hasBeenPersisted = true;
            _persistedStatus = local.status;
            _initialSnapshot = _currentSnapshot();
          }
          _errorMessage = _friendlyError(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _previewAndSend() async {
    final uuid = _persistedUuid;
    if (!_canSend || uuid == null) {
      return;
    }
    final loadCoordinator = AppDataScope.loadCoordinator(context);
    setState(() {
      _isBusy = true;
      _busyMessage = 'Preparando vista previa...';
      _errorMessage = null;
    });
    ManualNotificationAudiencePreview preview;
    try {
      preview = await AppDataScope.notificationDispatches(
        context,
      ).previewManualEvent(uuid);
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyError(error));
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
    if (!mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AdminNotificationSendDialog(preview: preview),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isBusy = true;
      _busyMessage = 'Enviando notificación...';
      _errorMessage = null;
    });
    try {
      final dispatchesController = AppDataScope.notificationDispatches(context);
      final acceptance = await dispatchesController.requestManualDispatch(uuid);
      await loadCoordinator.syncWithRemote(
        scope: AppLoadScope.adminNotificationDispatch,
      );
      if (!mounted) {
        return;
      }
      _showMessage(
        acceptance.reused
            ? 'Este envío ya había sido solicitado.'
            : 'El envío fue aceptado y continuará en segundo plano.',
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _friendlyError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _duplicateCompleted() async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AdminNotificationEventFormPage(
          event: widget.event,
          duplicate: true,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = _isCompleted;
    return Scaffold(
      body: AppSavingOverlay(
        isSaving: _isBusy,
        message: _busyMessage,
        detail: 'Conservaremos tus cambios de forma segura.',
        child: AppBackground(
          imageAsset: AppAssets.backgroundGarden,
          imageOpacity: 0.04,
          child: SafeArea(
            child: AppResponsiveContainer(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            AppBackButton(
                              onTap: _isBusy
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              enabled: !_isBusy,
                            ),
                            const Spacer(),
                            const AppLogo(width: 148),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          _isDuplicate
                              ? 'Duplicar notificación'
                              : widget.event == null
                              ? 'Nueva notificación'
                              : readOnly
                              ? 'Detalle de notificación'
                              : 'Editar notificación',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          readOnly
                              ? 'Esta configuración ya fue enviada y se conserva como historial.'
                              : _isAutomatic
                              ? 'Configura la regla que activará este aviso.'
                              : 'Configura el aviso manual antes de activarlo y enviarlo.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _FormCard(
                          title: 'Nombre interno',
                          icon: Icons.label_outline_rounded,
                          child: AppTextField(
                            controller: _nameController,
                            labelText: 'Nombre interno',
                            hintText: 'Nombre interno',
                            prefixIcon: Icons.label_outline_rounded,
                            readOnly: readOnly,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _FormCard(
                          title: 'Destino',
                          icon: Icons.route_outlined,
                          child: Column(
                            children: [
                              NotificationFormSelect(
                                label: 'Categoría',
                                value: _category,
                                items: notificationCategories,
                                labelFor: notificationCategoryLabel,
                                iconFor: notificationCategoryIcon,
                                enabled: !readOnly,
                                onChanged: (value) => setState(
                                  () => _category = value ?? _category,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              NotificationFormSelect(
                                label: 'Audiencia',
                                value: _audience,
                                items: notificationAudienceTypes,
                                labelFor: notificationAudienceLabel,
                                iconFor: notificationAudienceIcon,
                                enabled: !readOnly,
                                onChanged: (value) => setState(
                                  () => _audience = value ?? _audience,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              NotificationFormSelect(
                                label: 'Al pulsar la notificación',
                                value: _action,
                                items: notificationActionTypes,
                                labelFor: notificationActionLabel,
                                iconFor: notificationActionIcon,
                                enabled: !readOnly,
                                onChanged: (value) {
                                  setState(() {
                                    _action = value ?? _action;
                                    if (_action != 'open_content_item') {
                                      _contentUuid = null;
                                    }
                                  });
                                },
                              ),
                              if (_action == 'open_content_item' &&
                                  !_contentDestinationIsDynamic) ...[
                                const SizedBox(height: AppSpacing.md),
                                _ContentSelect(
                                  value: _contentUuid,
                                  items: _publishedContent,
                                  loaded: _contentLoaded,
                                  enabled: !readOnly,
                                  onChanged: (value) =>
                                      setState(() => _contentUuid = value),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        NotificationEventRuleCard(
                          triggerType: _triggerType,
                          triggerKey: _triggerKey,
                          executionMode: _executionMode,
                          triggerConfig: _triggerConfig,
                          startsAt: _startsAt,
                          endsAt: _endsAt,
                          enabled: !readOnly,
                          onTriggerTypeChanged: (value) {
                            setState(() {
                              _triggerType = value ?? _triggerType;
                              if (_triggerType == 'manual') {
                                _triggerKey = null;
                                _executionMode = 'once';
                                _triggerConfig = const {};
                              } else {
                                final keys = notificationTriggerKeysForType(
                                  _triggerType,
                                );
                                _triggerKey = keys.first;
                                _executionMode = 'per_occurrence';
                                _triggerConfig =
                                    defaultNotificationTriggerConfig(
                                      _triggerKey!,
                                    );
                              }
                              _configureAutomaticMessageTemplates();
                              _errorMessage = null;
                            });
                          },
                          onTriggerKeyChanged: (value) => setState(() {
                            _triggerKey = value;
                            _triggerConfig = value == null
                                ? const {}
                                : defaultNotificationTriggerConfig(value);
                            _configureAutomaticMessageTemplates();
                          }),
                          onExecutionModeChanged: (value) => setState(
                            () => _executionMode = value ?? _executionMode,
                          ),
                          onTriggerConfigChanged: (value) =>
                              setState(() => _triggerConfig = value),
                          onStartsAtChanged: (value) =>
                              setState(() => _startsAt = value),
                          onEndsAtChanged: (value) =>
                              setState(() => _endsAt = value),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        NotificationMessageTemplateFields(
                          triggerKey: _triggerKey,
                          titleTemplate: _titleController.text,
                          bodyTemplate: _bodyController.text,
                          enabled: !readOnly,
                          onTitleChanged: (value) {
                            _titleController.text = value;
                            _handleChanged();
                          },
                          onBodyChanged: (value) {
                            _bodyController.text = value;
                            _handleChanged();
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            AppDataScope.currentProfile(context),
                            AppDataScope.wellnessProfileStats(context),
                          ]),
                          builder: (context, _) => AdminNotificationPreviewCard(
                            internalName: _nameController.text,
                            title: _previewTitle,
                            body: _previewBody,
                            audienceType: _audience,
                            triggerType: _triggerType,
                            triggerKey: _triggerKey,
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        ..._buildActions(),
                        const SizedBox(height: 48),
                      ],
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

  List<Widget> _buildActions() {
    if (_isCompleted) {
      return [
        AppPrimaryButton(
          label: 'Duplicar',
          icon: Icons.copy_rounded,
          labelStyle: _notificationBegumTextStyle,
          onPressed: _isBusy ? null : _duplicateCompleted,
        ),
      ];
    }

    if (_persistedStatus == 'active') {
      final actions = <Widget>[
        AppPrimaryButton(
          label: 'Guardar cambios',
          icon: Icons.check_rounded,
          labelStyle: _notificationBegumTextStyle,
          onPressed: !_isBusy && _canSaveActive ? () => _save('active') : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSecondaryButton(
          label: 'Volver a borrador',
          icon: Icons.drafts_outlined,
          labelStyle: _notificationBegumTextStyle,
          onPressed: _isBusy ? null : () => _save('draft'),
        ),
      ];
      if (notificationEventAllowsManualSend(_triggerType)) {
        actions.addAll([
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            label: 'Enviar ahora',
            icon: Icons.send_rounded,
            labelStyle: _notificationBegumTextStyle,
            onPressed: _canSend ? _previewAndSend : null,
          ),
        ]);
      }
      return actions;
    }

    return [
      AppSecondaryButton(
        label: 'Guardar borrador',
        icon: Icons.drafts_outlined,
        labelStyle: _notificationBegumTextStyle,
        onPressed: _isBusy ? null : () => _save('draft'),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppPrimaryButton(
        label: 'Activar',
        icon: Icons.notifications_active_rounded,
        labelStyle: _notificationBegumTextStyle,
        onPressed: _isBusy ? null : () => _save('active'),
      ),
    ];
  }
}

class NotificationFormSelect extends StatelessWidget {
  const NotificationFormSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelFor,
    required this.onChanged,
    this.iconFor,
    this.enabled = true,
  });

  final String label;
  final String value;
  final List<String> items;
  final String Function(String value) labelFor;
  final ValueChanged<String?> onChanged;
  final IconData Function(String value)? iconFor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = constraints.maxWidth >= 540 ? 96.0 : 88.0;
        final scheme = Theme.of(context).colorScheme;
        final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: AppTypography.displayFont,
          fontFamilyFallback: AppTypography.fallbackFonts,
          fontWeight: FontWeight.w600,
        );
        return Column(
          key: ValueKey('$label-$value-$enabled'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: tileSize,
              child: SingleChildScrollView(
                key: const ValueKey('notification-options-carousel'),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final selected = item == value;
                    final icon = iconFor?.call(item) ?? Icons.tune_rounded;
                    final foreground = selected
                        ? scheme.onPrimary
                        : scheme.onSurface;
                    final background = selected
                        ? scheme.primary
                        : scheme.surface.withValues(
                            alpha: enabled ? 0.82 : 0.48,
                          );
                    final borderColor = selected
                        ? scheme.primary
                        : scheme.outlineVariant.withValues(
                            alpha: enabled ? 0.9 : 0.45,
                          );
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == items.length - 1 ? 0 : AppSpacing.xs,
                      ),
                      child: SizedBox(
                        width: tileSize,
                        height: tileSize,
                        child: Semantics(
                          button: true,
                          enabled: enabled,
                          selected: selected,
                          label: labelFor(item),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: enabled ? () => onChanged(item) : null,
                              borderRadius: AppRadius.medium,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                decoration: BoxDecoration(
                                  color: background,
                                  borderRadius: AppRadius.medium,
                                  border: Border.all(color: borderColor),
                                ),
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icon, color: foreground, size: 25),
                                    const SizedBox(height: AppSpacing.xxs),
                                    Text(
                                      labelFor(item),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontFamily:
                                                AppTypography.displayFont,
                                            fontFamilyFallback:
                                                AppTypography.fallbackFonts,
                                            color: foreground,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ContentSelect extends StatelessWidget {
  const _ContentSelect({
    required this.value,
    required this.items,
    required this.loaded,
    required this.enabled,
    required this.onChanged,
  });

  final String? value;
  final List<AppContentItem> items;
  final bool loaded;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (loaded && items.isEmpty) {
      return Text(
        'No hay contenido publicado disponible.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return DropdownButtonFormField<String>(
      key: ValueKey('content-$value-$loaded-$enabled'),
      style: _notificationBegumTextStyle,
      initialValue: items.any((item) => item.uuidContentItem == value)
          ? value
          : null,
      isExpanded: true,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.uuidContentItem,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  item.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _notificationBegumTextStyle,
                ),
              ),
            ),
          )
          .toList(growable: false),
      onChanged: enabled && loaded ? onChanged : null,
      decoration: const InputDecoration(
        labelText: 'Contenido publicado',
        hintText: 'Selecciona un contenido',
      ),
    );
  }
}

class NotificationEventRuleCard extends StatelessWidget {
  const NotificationEventRuleCard({
    super.key,
    required this.triggerType,
    required this.triggerKey,
    required this.executionMode,
    this.triggerConfig = const {},
    required this.startsAt,
    required this.endsAt,
    required this.enabled,
    required this.onTriggerTypeChanged,
    required this.onTriggerKeyChanged,
    required this.onExecutionModeChanged,
    this.onTriggerConfigChanged,
    required this.onStartsAtChanged,
    required this.onEndsAtChanged,
  });

  final String triggerType;
  final String? triggerKey;
  final String executionMode;
  final Map<String, dynamic> triggerConfig;
  final DateTime startsAt;
  final DateTime? endsAt;
  final bool enabled;
  final ValueChanged<String?> onTriggerTypeChanged;
  final ValueChanged<String?> onTriggerKeyChanged;
  final ValueChanged<String?> onExecutionModeChanged;
  final ValueChanged<Map<String, dynamic>>? onTriggerConfigChanged;
  final ValueChanged<DateTime> onStartsAtChanged;
  final ValueChanged<DateTime?> onEndsAtChanged;

  @override
  Widget build(BuildContext context) {
    final isAutomatic = triggerType != 'manual';
    final triggerKeys = notificationTriggerKeysForForm(
      triggerType,
      currentKey: triggerKey,
    );
    return _FormCard(
      title: 'Regla de activación',
      icon: Icons.event_repeat_outlined,
      child: Column(
        children: [
          NotificationFormSelect(
            label: 'Tipo de disparador',
            value: triggerType,
            items: notificationEventTriggerTypes,
            labelFor: notificationTriggerTypeLabel,
            iconFor: notificationTriggerTypeIcon,
            enabled: enabled,
            onChanged: onTriggerTypeChanged,
          ),
          if (isAutomatic) ...[
            const SizedBox(height: AppSpacing.md),
            NotificationFormSelect(
              label: 'Evento que la activa',
              value: triggerKey ?? triggerKeys.first,
              items: triggerKeys,
              labelFor: notificationTriggerKeyLabel,
              iconFor: notificationTriggerKeyIcon,
              enabled: enabled,
              onChanged: onTriggerKeyChanged,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          NotificationFormSelect(
            label: 'Modo de ejecución',
            value: executionMode,
            items: notificationEventExecutionModes,
            labelFor: notificationExecutionModeLabel,
            iconFor: notificationExecutionModeIcon,
            enabled: enabled && isAutomatic,
            onChanged: onExecutionModeChanged,
          ),
          if (triggerKey == 'schedule.interval') ...[
            const SizedBox(height: AppSpacing.md),
            NotificationFormSelect(
              label: 'Frecuencia',
              value: _intervalPreset(triggerConfig),
              items: notificationScheduleIntervalPresets,
              labelFor: _intervalPresetLabel,
              iconFor: notificationScheduleIntervalIcon,
              enabled: enabled,
              onChanged: (value) {
                if (value != null) {
                  onTriggerConfigChanged?.call(_intervalConfig(value));
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            const _UserLocalTimezoneHint(),
          ],
          if (triggerKey == 'schedule.at_time') ...[
            const SizedBox(height: AppSpacing.md),
            NotificationLocalTimeField(
              label: 'Hora local',
              value: _configString(
                triggerConfig,
                'local_time',
                fallback: '08:00',
              ),
              enabled: enabled,
              onChanged: (value) => onTriggerConfigChanged?.call({
                ...triggerConfig,
                'local_time': value,
                'timezone_mode': 'user_local',
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _UserLocalTimezoneHint(),
          ],
          if (triggerKey == 'progress.streak_reminder') ...[
            const SizedBox(height: AppSpacing.md),
            NotificationLocalTimeField(
              label: 'Hora del recordatorio',
              value: _configString(
                triggerConfig,
                'reminder_time',
                fallback: '20:00',
              ),
              enabled: enabled,
              onChanged: (value) => onTriggerConfigChanged?.call({
                ...triggerConfig,
                'reminder_time': value,
                'timezone_mode': 'user_local',
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _UserLocalTimezoneHint(),
          ],
          if (triggerKey == 'progress.streak_milestone') ...[
            const SizedBox(height: AppSpacing.md),
            _MilestoneSelector(
              selected: _selectedMilestones(triggerConfig),
              enabled: enabled,
              onChanged: (values) => onTriggerConfigChanged?.call({
                ...triggerConfig,
                'milestones': values,
                'timezone_mode': 'user_local',
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _UserLocalTimezoneHint(),
          ],
          const SizedBox(height: AppSpacing.md),
          NotificationDateTimeField(
            label: 'Fecha inicial',
            value: startsAt,
            enabled: enabled,
            onChanged: (value) {
              if (value != null) {
                onStartsAtChanged(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          NotificationDateTimeField(
            label: 'Fecha final',
            value: endsAt,
            enabled: enabled,
            allowClear: true,
            onChanged: onEndsAtChanged,
          ),
        ],
      ),
    );
  }
}

class NotificationLocalTimeField extends StatelessWidget {
  const NotificationLocalTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  Future<void> _pick(BuildContext context) async {
    final parts = value.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: int.tryParse(parts.last) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) {
      return;
    }
    onChanged(
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.schedule_outlined),
      ),
      child: InkWell(
        onTap: enabled ? () => _pick(context) : null,
        borderRadius: AppRadius.medium,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(value),
        ),
      ),
    );
  }
}

class _UserLocalTimezoneHint extends StatelessWidget {
  const _UserLocalTimezoneHint();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Hora local de cada usuario',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class NotificationAutomaticMessageFields extends StatelessWidget {
  const NotificationAutomaticMessageFields({
    super.key,
    required this.triggerKey,
    required this.prefixController,
    required this.suffixController,
    required this.enabled,
    required this.onChanged,
  });

  final String triggerKey;
  final TextEditingController prefixController;
  final TextEditingController suffixController;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _FormCard(
      title: 'Título y mensaje',
      icon: Icons.edit_notifications_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personaliza el mensaje',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Título automático'),
            child: Text(notificationAutomaticTitleTemplate(triggerKey)),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: prefixController,
            labelText: 'Antes del mensaje',
            hintText: 'Texto opcional',
            prefixIcon: Icons.format_align_left_rounded,
            readOnly: !enabled,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: suffixController,
            labelText: 'Después del mensaje',
            hintText: 'Texto opcional',
            prefixIcon: Icons.format_align_right_rounded,
            readOnly: !enabled,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: AppSpacing.md),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Mensaje de ejemplo'),
            child: Text(
              notificationAutomaticPreviewBody(
                triggerKey,
                prefix: prefixController.text,
                suffix: suffixController.text,
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationMessageTemplateFields extends StatelessWidget {
  const NotificationMessageTemplateFields({
    super.key,
    required this.triggerKey,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.enabled,
    required this.onTitleChanged,
    required this.onBodyChanged,
  });

  final String? triggerKey;
  final String titleTemplate;
  final String bodyTemplate;
  final bool enabled;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onBodyChanged;

  @override
  Widget build(BuildContext context) {
    final variables = notificationTemplateVariablesForTrigger(triggerKey);
    return _FormCard(
      title: 'Título y mensaje',
      icon: Icons.edit_notifications_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agrega texto o referencias personalizadas.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          NotificationTemplateEditor(
            key: ValueKey('notification-title-$triggerKey'),
            label: 'Título',
            initialTemplate: titleTemplate,
            variables: variables,
            enabled: enabled,
            hintText: 'Escribe el título',
            maxLines: 2,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          NotificationTemplateEditor(
            key: ValueKey('notification-body-$triggerKey'),
            label: 'Mensaje',
            initialTemplate: bodyTemplate,
            variables: variables,
            enabled: enabled,
            hintText: 'Escribe el mensaje',
            maxLines: 5,
            onChanged: onBodyChanged,
          ),
        ],
      ),
    );
  }
}

class _MilestoneSelector extends StatelessWidget {
  const _MilestoneSelector({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final List<int> selected;
  final bool enabled;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Objetivos de racha'),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: notificationStreakMilestonePresets
            .map((milestone) {
              final isSelected = selected.contains(milestone);
              return FilterChip(
                labelStyle: _notificationBegumTextStyle,
                label: Text('$milestone días'),
                selected: isSelected,
                onSelected: enabled
                    ? (value) {
                        final next = [...selected];
                        if (value) {
                          next.add(milestone);
                        } else {
                          next.remove(milestone);
                        }
                        next.sort();
                        onChanged(next);
                      }
                    : null,
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

String _configString(
  Map<String, dynamic> config,
  String key, {
  required String fallback,
}) {
  final value = config[key];
  return value is String && value.isNotEmpty ? value : fallback;
}

List<int> _selectedMilestones(Map<String, dynamic> config) {
  final values = config['milestones'];
  if (values is List) {
    final selected = values.whereType<int>().toList()..sort();
    if (selected.isNotEmpty) {
      return selected;
    }
  }
  return [3, 7, 14, 30];
}

String _intervalPreset(Map<String, dynamic> config) {
  final value = config['interval_value'];
  final unit = config['interval_unit'];
  if (value == 12 && unit == 'hours') {
    return '12_hours';
  }
  if (value == 1 && unit == 'days') {
    return '1_day';
  }
  if (value == 2 && unit == 'days') {
    return '2_days';
  }
  return '12_hours';
}

String _intervalPresetLabel(String value) => switch (value) {
  '1_day' => 'Cada día',
  '2_days' => 'Cada 2 días',
  _ => 'Cada 12 horas',
};

Map<String, dynamic> _intervalConfig(String preset) => switch (preset) {
  '1_day' => {
    'interval_value': 1,
    'interval_unit': 'days',
    'timezone_mode': 'user_local',
  },
  '2_days' => {
    'interval_value': 2,
    'interval_unit': 'days',
    'timezone_mode': 'user_local',
  },
  _ => {
    'interval_value': 12,
    'interval_unit': 'hours',
    'timezone_mode': 'user_local',
  },
};

class NotificationDateTimeField extends StatelessWidget {
  const NotificationDateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.allowClear = false,
  });

  final String label;
  final DateTime? value;
  final bool enabled;
  final bool allowClear;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final initial = value?.toLocal() ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return;
    }
    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute).toUtc(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null
        ? 'Sin fecha final'
        : notificationDateTimeLabel(value!);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: enabled && allowClear && value != null
            ? IconButton(
                tooltip: 'Quitar fecha final',
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close_rounded),
              )
            : const Icon(Icons.calendar_month_outlined),
      ),
      child: InkWell(
        onTap: enabled ? () => _pick(context) : null,
        borderRadius: AppRadius.medium,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(displayValue),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stroke = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 9),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: AppTypography.displayFont,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class AdminNotificationSendDialog extends StatelessWidget {
  const AdminNotificationSendDialog({super.key, required this.preview});

  final ManualNotificationAudiencePreview preview;

  @override
  Widget build(BuildContext context) {
    final canSend = preview.targetProfileCount > 0;
    return AlertDialog(
      icon: const AppLogo(compact: true, width: 44),
      title: const Text('Confirmar envío', textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(preview.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(preview.body),
            const SizedBox(height: 14),
            Text(
              'Audiencia: ${notificationAudienceLabel(preview.audienceType)}',
            ),
            Text('Destino: ${notificationActionLabel(preview.actionType)}'),
            const SizedBox(height: 12),
            Text(
              '${notificationPeopleCountLabel(preview.targetProfileCount)} con aviso',
            ),
            Text(
              '${notificationDeviceCountLabel(preview.targetDeviceCount)} disponibles',
            ),
            if (!canSend) ...[
              const SizedBox(height: 12),
              Text(
                'No hay personas para enviar este aviso.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ] else if (preview.targetDeviceCount == 0) ...[
              const SizedBox(height: 12),
              const Text(
                'Se guardará el aviso en la app, pero no habrá notificación push porque no hay dispositivos disponibles.',
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(textStyle: _notificationBegumTextStyle),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(canSend ? 'Cancelar' : 'Cerrar'),
        ),
        if (canSend)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              textStyle: _notificationBegumTextStyle,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.send_rounded),
            label: const Text('Enviar'),
          ),
      ],
    );
  }
}

class _NotificationFormSnapshot {
  const _NotificationFormSnapshot({
    required this.name,
    required this.title,
    required this.body,
    required this.category,
    required this.audience,
    required this.action,
    required this.triggerType,
    required this.triggerKey,
    required this.executionMode,
    required this.triggerConfigJson,
    required this.startsAt,
    required this.endsAt,
    required this.contentUuid,
  });

  final String name;
  final String title;
  final String body;
  final String category;
  final String audience;
  final String action;
  final String triggerType;
  final String? triggerKey;
  final String executionMode;
  final String triggerConfigJson;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? contentUuid;

  @override
  bool operator ==(Object other) {
    return other is _NotificationFormSnapshot &&
        other.name == name &&
        other.title == title &&
        other.body == body &&
        other.category == category &&
        other.audience == audience &&
        other.action == action &&
        other.triggerType == triggerType &&
        other.triggerKey == triggerKey &&
        other.executionMode == executionMode &&
        other.triggerConfigJson == triggerConfigJson &&
        other.startsAt == startsAt &&
        other.endsAt == endsAt &&
        other.contentUuid == contentUuid;
  }

  @override
  int get hashCode => Object.hash(
    name,
    title,
    body,
    category,
    audience,
    action,
    triggerType,
    triggerKey,
    executionMode,
    triggerConfigJson,
    startsAt,
    endsAt,
    contentUuid,
  );
}

String _friendlyError(Object error) {
  final text = error.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '').trim();
  return text.isEmpty ? 'No se pudo guardar la notificación.' : text;
}

String _generateUuidV4() {
  final random = math.Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hexByte(int value) => value.toRadixString(16).padLeft(2, '0');
  final hex = bytes.map(hexByte).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
