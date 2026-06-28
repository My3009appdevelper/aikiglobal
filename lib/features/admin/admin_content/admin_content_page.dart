import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../core/data/models/app_content_item.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/content_items_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_refresh_indicator.dart';
import '../../../shared/widgets/app_responsive_container.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/my_image.dart';
import 'admin_content_form_page.dart';

enum AdminContentFilter { all, published, draft, archived }

enum AdminContentTypeFilter {
  all,
  course,
  meditation,
  audio,
  sound,
  event,
  session,
}

class AdminContentPage extends StatefulWidget {
  const AdminContentPage({super.key});

  @override
  State<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends State<AdminContentPage> {
  final _searchController = TextEditingController();
  AdminContentFilter _filter = AdminContentFilter.all;
  AdminContentTypeFilter _typeFilter = AdminContentTypeFilter.all;
  bool _initialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _initialized = true;
    AppDataScope.contentItems(context).watchAdminAll();
  }

  Future<void> _refresh() {
    return AppDataScope.contentItems(
      context,
    ).refreshFromRemote(includeAdminPush: true);
  }

  Future<void> _openForm({AppContentItem? item}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AdminContentFormPage(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppDataScope.contentItems(context);

    return SafeArea(
      bottom: false,
      child: AppResponsiveContainer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final items = _filteredItems(controller.items);

            return AppRefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        const AppLogo(width: 148),
                        const SizedBox(height: AppSpacing.lg),
                        _AdminContentHeader(
                          total: controller.items.length,
                          published: _countByStatus(
                            controller.items,
                            'published',
                          ),
                          drafts: _countByStatus(controller.items, 'draft'),
                          archived: _countByStatus(
                            controller.items,
                            'archived',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppPrimaryButton(
                          label: 'Nuevo contenido',
                          icon: Icons.add_rounded,
                          onPressed: () => _openForm(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          controller: _searchController,
                          hintText: 'Buscar contenido',
                          prefixIcon: Icons.search_rounded,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _AdminContentFilters(
                          selected: _filter,
                          onChanged: (filter) =>
                              setState(() => _filter = filter),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _AdminContentTypeFilters(
                          selected: _typeFilter,
                          onChanged: (filter) =>
                              setState(() => _typeFilter = filter),
                        ),
                        if (controller.isSyncing || controller.isLoading) ...[
                          const SizedBox(height: AppSpacing.md),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                        if (controller.error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          _AdminContentMessage(
                            icon: Icons.warning_amber_rounded,
                            title: 'No se pudo sincronizar el contenido',
                            body:
                                'Revisa tu conexión o permisos de administrador.',
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        if (items.isEmpty)
                          _AdminContentMessage(
                            icon: Icons.inventory_2_outlined,
                            title: 'No hay contenido para mostrar',
                            body:
                                'Crea un contenido nuevo o cambia el filtro actual.',
                          )
                        else
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: _AdminContentCard(
                                item: item,
                                onEdit: () => _openForm(item: item),
                                onPublish: () =>
                                    _setStatus(controller, item, 'published'),
                                onDraft: () =>
                                    _setStatus(controller, item, 'draft'),
                                onArchive: () =>
                                    _setStatus(controller, item, 'archived'),
                              ),
                            ),
                          ),
                        const SizedBox(height: 130),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _setStatus(
    ContentItemsController controller,
    AppContentItem item,
    String status,
  ) async {
    await controller.updateStatus(
      item.uuidContentItem,
      status: status,
      syncAfterUpdate: true,
    );
  }

  List<AppContentItem> _filteredItems(List<AppContentItem> source) {
    final query = _searchController.text.trim().toLowerCase();

    return source.where((item) {
      final matchesStatus = switch (_filter) {
        AdminContentFilter.published => item.status == 'published',
        AdminContentFilter.draft => item.status == 'draft',
        AdminContentFilter.archived => item.status == 'archived',
        AdminContentFilter.all => item.deletedAt == null,
      };

      if (!matchesStatus) {
        return false;
      }

      final matchesType = switch (_typeFilter) {
        AdminContentTypeFilter.all => true,
        AdminContentTypeFilter.course => _normalizedType(item.tipo) == 'course',
        AdminContentTypeFilter.meditation =>
          _normalizedType(item.tipo) == 'meditation',
        AdminContentTypeFilter.audio => _normalizedType(item.tipo) == 'audio',
        AdminContentTypeFilter.sound => _normalizedType(item.tipo) == 'sound',
        AdminContentTypeFilter.event => _normalizedType(item.tipo) == 'event',
        AdminContentTypeFilter.session =>
          _normalizedType(item.tipo) == 'session',
      };

      if (!matchesType) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final haystack = [
        item.tipo,
        item.titulo,
        item.subtitulo,
        item.descripcion,
        item.status,
      ].whereType<String>().join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }
}

class _AdminContentHeader extends StatelessWidget {
  const _AdminContentHeader({
    required this.total,
    required this.published,
    required this.drafts,
    required this.archived,
  });

  final int total;
  final int published;
  final int drafts;
  final int archived;

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
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contenido', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Administra publicaciones, borradores y contenido archivado.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _AdminContentStat(label: 'Total', value: total),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AdminContentStat(label: 'Publicado', value: published),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AdminContentStat(label: 'Borradores', value: drafts),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AdminContentStat(label: 'Archivado', value: archived),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminContentStat extends StatelessWidget {
  const _AdminContentStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AdminContentFilters extends StatelessWidget {
  const _AdminContentFilters({required this.selected, required this.onChanged});

  final AdminContentFilter selected;
  final ValueChanged<AdminContentFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AdminContentFilter.values.map((filter) {
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _FilterChipButton(
              label: _filterLabel(filter),
              selected: isSelected,
              onTap: () => onChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AdminContentTypeFilters extends StatelessWidget {
  const _AdminContentTypeFilters({
    required this.selected,
    required this.onChanged,
  });

  final AdminContentTypeFilter selected;
  final ValueChanged<AdminContentTypeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AdminContentTypeFilter.values.map((filter) {
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _FilterChipButton(
              label: _typeFilterLabel(filter),
              selected: isSelected,
              onTap: () => onChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final background = selected
        ? Theme.of(context).colorScheme.primary
        : (brightness == Brightness.dark
              ? AppColors.darkSurfaceSoft
              : AppColors.sandLight);
    final foreground = selected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return AppInteractive(
      tooltip: label,
      borderRadius: AppRadius.full,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.full,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AdminContentCard extends StatelessWidget {
  const _AdminContentCard({
    required this.item,
    required this.onEdit,
    required this.onPublish,
    required this.onDraft,
    required this.onArchive,
  });

  final AppContentItem item;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onDraft;
  final VoidCallback onArchive;

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyImage(
            initials: _typeInitials(item.tipo),
            imagePath: _coverPath(item),
            resolveImageUrl: AppDataScope.contentItems(
              context,
            ).resolveCoverImageUrl,
            size: 78,
            circle: false,
            borderRadius: AppRadius.medium,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _SmallBadge(label: _typeLabel(item.tipo)),
                    _SmallBadge(label: _statusLabel(item.status)),
                    if (item.destacado) const _SmallBadge(label: 'Destacado'),
                    if (item.hasPendingSync)
                      const _SmallBadge(label: 'Pendiente'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if ((item.subtitulo ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitulo!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _IconAction(
                      tooltip: 'Editar',
                      icon: Icons.edit_outlined,
                      onTap: onEdit,
                    ),
                    if (item.status != 'published')
                      _IconAction(
                        tooltip: 'Publicar',
                        icon: Icons.publish_rounded,
                        onTap: onPublish,
                      ),
                    if (item.status != 'draft')
                      _IconAction(
                        tooltip: 'Enviar a borrador',
                        icon: Icons.drafts_outlined,
                        onTap: onDraft,
                      ),
                    if (item.status != 'archived')
                      _IconAction(
                        tooltip: 'Archivar',
                        icon: Icons.archive_outlined,
                        onTap: onArchive,
                      ),
                  ],
                ),
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

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      hoverScale: 1,
      pressedScale: 1,
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _AdminContentMessage extends StatelessWidget {
  const _AdminContentMessage({
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
        : AppColors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.9),
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
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

int _countByStatus(List<AppContentItem> items, String status) {
  return items.where((item) => item.status == status).length;
}

String _filterLabel(AdminContentFilter filter) {
  return switch (filter) {
    AdminContentFilter.all => 'Todo',
    AdminContentFilter.published => 'Publicado',
    AdminContentFilter.draft => 'Borradores',
    AdminContentFilter.archived => 'Archivado',
  };
}

String _typeFilterLabel(AdminContentTypeFilter filter) {
  return switch (filter) {
    AdminContentTypeFilter.all => 'Todos',
    AdminContentTypeFilter.course => 'Cursos',
    AdminContentTypeFilter.meditation => 'Meditaciones',
    AdminContentTypeFilter.audio => 'Audio',
    AdminContentTypeFilter.sound => 'Sonido',
    AdminContentTypeFilter.event => 'Eventos',
    AdminContentTypeFilter.session => 'Sesiones',
  };
}

String _statusLabel(String status) {
  return switch (status.trim().toLowerCase()) {
    'published' => 'Publicado',
    'draft' => 'Borrador',
    'archived' => 'Archivado',
    _ => status,
  };
}

String _typeLabel(String tipo) {
  return switch (tipo.trim().toLowerCase()) {
    'course' => 'Curso',
    'meditation' => 'Meditación',
    'audio' => 'Audio',
    'sound' => 'Sonido',
    'event' => 'Evento',
    'session' => 'Sesión',
    _ => tipo,
  };
}

String _typeInitials(String tipo) {
  final label = _typeLabel(tipo);
  return label.length <= 2
      ? label.toUpperCase()
      : label.substring(0, 2).toUpperCase();
}

String _normalizedType(String? value) {
  return value?.trim().toLowerCase() ?? '';
}

String? _coverPath(AppContentItem item) {
  if (!kIsWeb) {
    final localPath = item.coverPathLocal?.trim();
    if (localPath != null && localPath.isNotEmpty) {
      return localPath;
    }
  }

  final remotePath = item.coverPathSupabase?.trim();
  if (remotePath != null && remotePath.isNotEmpty) {
    return remotePath;
  }

  return null;
}
