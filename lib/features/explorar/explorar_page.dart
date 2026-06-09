import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/models/app_content_item.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/content_items_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_responsive_container.dart';
import '../../shared/widgets/app_section_header.dart';
import 'content_detail_page.dart';
import 'data/mock_explore_data.dart';
import 'models/content_item.dart';
import 'widgets/content_horizontal_list.dart';
import 'widgets/explore_hero_card.dart';
import 'widgets/quick_category_row.dart';

class ExplorarPage extends StatefulWidget {
  const ExplorarPage({super.key});

  @override
  State<ExplorarPage> createState() => _ExplorarPageState();
}

class _ExplorarPageState extends State<ExplorarPage> {
  final _searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    final contentController = AppDataScope.contentItems(context);
    final profileController = AppDataScope.currentProfile(context);

    if (profileController.isAdminView) {
      contentController.watchAdminAll();
    } else {
      contentController.watchPublished();
    }
  }

  void _openContent(BuildContext context, ContentItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ContentDetailPage(item: item)),
    );
  }

  Future<void> _search(String query) async {
    final controller = AppDataScope.contentItems(context);
    if (query.trim().isEmpty) {
      if (controller.adminMode) {
        controller.watchAdminAll();
      } else {
        controller.watchPublished();
      }
      return;
    }

    if (controller.adminMode) {
      await controller.searchAdminAll(query);
    } else {
      await controller.searchPublished(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentController = AppDataScope.contentItems(context);

    return SafeArea(
      bottom: false,
      child: AppResponsiveContainer(
        child: AnimatedBuilder(
          animation: contentController,
          builder: (context, _) {
            final data = _ExploreViewData.fromController(
              contentController,
              fallbackQuery: _searchController.text,
              allowMockFallback: !contentController.hasRemote,
            );

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _ExploreHeader(
                        controller: _searchController,
                        onSubmitted: _search,
                      ),
                      if (contentController.adminMode) ...[
                        const SizedBox(height: AppSpacing.md),
                        const _AdminViewBanner(),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      ExploreHeroCard(
                        onTap: () => _openContent(context, data.heroItem),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const QuickCategoryRow(),
                      if (contentController.hasRemote &&
                          contentController.error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _RemoteSectionError(error: contentController.error),
                      ],
                      if (contentController.hasRemote &&
                          contentController.error == null &&
                          !data.hasAnySection) ...[
                        const SizedBox(height: AppSpacing.md),
                        const _NoRemoteContent(),
                      ],
                      if (_searchController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        AppSectionHeader(
                          title: 'Resultados',
                          actionLabel: 'Limpiar',
                          onAction: () {
                            _searchController.clear();
                            _search('');
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ContentHorizontalList(
                          items: data.searchResults,
                          onItemTap: (item) => _openContent(context, item),
                        ),
                      ] else ...[
                        _Section(
                          title: 'Cursos disponibles',
                          items: data.courses,
                          onItemTap: (item) => _openContent(context, item),
                        ),
                        _Section(
                          title: 'Meditaciones',
                          items: data.meditations,
                          onItemTap: (item) => _openContent(context, item),
                        ),
                        _Section(
                          title: 'Eventos',
                          items: data.events,
                          onItemTap: (item) => _openContent(context, item),
                        ),
                        _Section(
                          title: 'Audio y sonido',
                          items: data.audios,
                          onItemTap: (item) => _openContent(context, item),
                        ),
                        _Section(
                          title: 'Recomendados para ti',
                          items: data.recommended,
                          cardWidth: 172,
                          onItemTap: (item) => _openContent(context, item),
                        ),
                      ],
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.onItemTap,
    this.cardWidth = 174,
  });

  final String title;
  final List<ContentItem> items;
  final ValueChanged<ContentItem> onItemTap;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        AppSectionHeader(
          title: title,
          actionLabel: 'Ver todos',
          onAction: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        ContentHorizontalList(
          items: items,
          cardWidth: cardWidth,
          onItemTap: onItemTap,
        ),
      ],
    );
  }
}

class _RemoteSectionError extends StatelessWidget {
  const _RemoteSectionError({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Text(
        'No se pudieron cargar contenidos desde Supabase (${error.runtimeType}). Verifica sesion, permisos RLS o API key.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _NoRemoteContent extends StatelessWidget {
  const _NoRemoteContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'No hay contenidos publicados para mostrar desde Supabase.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _AdminViewBanner extends StatelessWidget {
  const _AdminViewBanner();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.sandLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.86),
        borderRadius: AppRadius.medium,
        border: Border.all(
          color: brightness == Brightness.dark
              ? AppColors.darkStroke
              : AppColors.stroke,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vista admin: mostrando contenido local completo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreViewData {
  const _ExploreViewData({
    required this.courses,
    required this.meditations,
    required this.events,
    required this.audios,
    required this.recommended,
    required this.searchResults,
  });

  factory _ExploreViewData.fromController(
    ContentItemsController controller, {
    required String fallbackQuery,
    required bool allowMockFallback,
  }) {
    final realItems = controller.items;
    if (realItems.isEmpty && allowMockFallback) {
      return _ExploreViewData._fallback(fallbackQuery);
    }
    if (realItems.isEmpty) {
      return const _ExploreViewData(
        courses: [],
        meditations: [],
        events: [],
        audios: [],
        recommended: [],
        searchResults: [],
      );
    }

    final visualItems = realItems.asMap().entries.map((entry) {
      return _mapContentItem(entry.value, entry.key);
    }).toList();

    return _ExploreViewData(
      courses: _filterByType(visualItems, {'course', 'curso'}),
      meditations: _filterByType(visualItems, {'meditation', 'meditacion'}),
      events: _filterByType(visualItems, {'event', 'evento'}),
      audios: _filterByType(visualItems, {'audio', 'sound', 'sonido'}),
      recommended: controller.featuredItems.isEmpty
          ? visualItems.take(8).toList()
          : controller.featuredItems.asMap().entries.map((entry) {
              return _mapContentItem(entry.value, entry.key);
            }).toList(),
      searchResults: visualItems,
    );
  }

  factory _ExploreViewData._fallback(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return const _ExploreViewData(
        courses: MockExploreData.courses,
        meditations: MockExploreData.meditations,
        events: MockExploreData.events,
        audios: MockExploreData.audios,
        recommended: MockExploreData.recommended,
        searchResults: MockExploreData.recommended,
      );
    }

    final results =
        [
          ...MockExploreData.courses,
          ...MockExploreData.meditations,
          ...MockExploreData.events,
          ...MockExploreData.audios,
        ].where((item) {
          return item.title.toLowerCase().contains(cleanQuery) ||
              item.type.toLowerCase().contains(cleanQuery) ||
              (item.description?.toLowerCase().contains(cleanQuery) ?? false);
        }).toList();

    return _ExploreViewData(
      courses: const [],
      meditations: const [],
      events: const [],
      audios: const [],
      recommended: const [],
      searchResults: results,
    );
  }

  final List<ContentItem> courses;
  final List<ContentItem> meditations;
  final List<ContentItem> events;
  final List<ContentItem> audios;
  final List<ContentItem> recommended;
  final List<ContentItem> searchResults;

  bool get hasAnySection =>
      courses.isNotEmpty ||
      meditations.isNotEmpty ||
      events.isNotEmpty ||
      audios.isNotEmpty ||
      recommended.isNotEmpty ||
      searchResults.isNotEmpty;

  ContentItem get heroItem {
    return courses.isNotEmpty
        ? courses.first
        : recommended.isNotEmpty
        ? recommended.first
        : MockExploreData.courses.first;
  }

  static List<ContentItem> _filterByType(
    List<ContentItem> items,
    Set<String> acceptedTypes,
  ) {
    return items.where((item) {
      return acceptedTypes.contains(_normalizeType(item.type));
    }).toList();
  }

  static ContentItem _mapContentItem(AppContentItem item, int index) {
    return ContentItem(
      title: item.titulo,
      type: _displayType(item.tipo),
      duration: _formatDuration(item.duracionSegundos),
      imageAsset: _fallbackAssetForType(item.tipo, index),
      description: item.descripcion ?? item.subtitulo,
      isNew: item.destacado,
      isFavorite: item.destacado,
    );
  }

  static String _displayType(String value) {
    return switch (_normalizeType(value)) {
      'course' || 'curso' => 'Curso',
      'meditation' || 'meditacion' => 'Meditación',
      'event' || 'evento' => 'Evento',
      'sound' || 'sonido' => 'Sonido',
      'audio' => 'Audio',
      'session' || 'sesion' => 'Sesión',
      _ => value,
    };
  }

  static String _normalizeType(String value) {
    return value.trim().toLowerCase();
  }

  static String _formatDuration(int? seconds) {
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

  static String _fallbackAssetForType(String tipo, int index) {
    final normalized = _normalizeType(tipo);
    final assets = switch (normalized) {
      'course' || 'curso' => const [
        AppAssets.curso1,
        AppAssets.curso2,
        AppAssets.curso3,
        AppAssets.curso4,
        AppAssets.curso5,
        AppAssets.curso6,
        AppAssets.curso7,
        AppAssets.curso8,
      ],
      'meditation' || 'meditacion' => const [
        AppAssets.meditacion1,
        AppAssets.meditacion2,
        AppAssets.meditacion3,
        AppAssets.meditacion4,
        AppAssets.meditacion5,
        AppAssets.meditacion6,
        AppAssets.meditacion7,
        AppAssets.meditacion8,
        AppAssets.meditacion9,
      ],
      'event' || 'evento' => const [
        AppAssets.evento1,
        AppAssets.evento2,
        AppAssets.evento3,
        AppAssets.evento4,
        AppAssets.evento5,
        AppAssets.evento6,
        AppAssets.evento7,
        AppAssets.evento8,
      ],
      _ => const [
        AppAssets.audio1,
        AppAssets.audio2,
        AppAssets.audio3,
        AppAssets.audio4,
        AppAssets.audio5,
        AppAssets.audio6,
        AppAssets.audio7,
        AppAssets.audio8,
      ],
    };

    return assets[index % assets.length];
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(width: 148),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.72),
            borderRadius: AppRadius.full,
            border: Border.all(color: stroke),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: brightness == Brightness.dark
                    ? AppColors.darkTextMuted
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  onChanged: (value) {
                    if (value.trim().isEmpty) {
                      onSubmitted(value);
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar',
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return IconButton(
                    tooltip: 'Limpiar búsqueda',
                    onPressed: () {
                      controller.clear();
                      onSubmitted('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
