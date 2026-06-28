import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/models/app_content_item.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/data/providers/content_items_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../../shared/widgets/app_responsive_container.dart';
import '../../shared/widgets/app_section_header.dart';
import '../../shared/widgets/app_text_field.dart';
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
  QuickCategoryType? _selectedCategory;
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
    if (query.trim().isNotEmpty && _selectedCategory != null) {
      setState(() => _selectedCategory = null);
    }

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

  void _selectCategory(QuickCategoryType type) {
    final shouldClearSearch = _searchController.text.trim().isNotEmpty;
    setState(() {
      _selectedCategory = _selectedCategory == type ? null : type;
    });

    if (shouldClearSearch) {
      _searchController.clear();
      unawaited(_search(''));
    }
  }

  Future<void> _refreshExplore() async {
    final contentController = AppDataScope.contentItems(context);
    final profileController = AppDataScope.currentProfile(context);
    final userContentStatesController = AppDataScope.userContentStates(context);
    final profile = profileController.profile;

    await contentController.refreshFromRemote();

    if (profile != null) {
      await userContentStatesController.syncWithRemote(
        uuidProfile: profile.uuidProfile,
      );
    }

    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      await _search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentController = AppDataScope.contentItems(context);
    final userContentStatesController = AppDataScope.userContentStates(context);

    return SafeArea(
      bottom: false,
      child: AppResponsiveContainer(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            contentController,
            userContentStatesController,
          ]),
          builder: (context, _) {
            final data = _ExploreViewData.fromController(
              contentController,
              favoriteContentIds:
                  userContentStatesController.favoriteContentIds,
              fallbackQuery: _searchController.text,
              allowMockFallback: !contentController.hasRemote,
            );

            return AppRefreshIndicator(
              onRefresh: _refreshExplore,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                        QuickCategoryRow(
                          audioCount: data.audios.length,
                          meditationCount: data.meditations.length,
                          courseCount: data.courses.length,
                          favoriteCount: data.favorites.length,
                          selectedType: _selectedCategory,
                          onSelected: _selectCategory,
                        ),
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
                        ] else if (_selectedCategory != null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          AppSectionHeader(
                            title: data.titleForCategory(_selectedCategory!),
                            actionLabel: 'Ver todo',
                            onAction: () {
                              setState(() => _selectedCategory = null);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (data.itemsForCategory(_selectedCategory!).isEmpty)
                            _EmptyCategoryResult(
                              title: data.titleForCategory(_selectedCategory!),
                            )
                          else
                            ContentHorizontalList(
                              items: data.itemsForCategory(_selectedCategory!),
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
              ),
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
          actionLabel: 'Ver todo',
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
        'No se pudieron cargar contenidos desde Supabase (${error.runtimeType}). Verifica sesión, permisos RLS o API key.',
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

class _EmptyCategoryResult extends StatelessWidget {
  const _EmptyCategoryResult({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.medium,
      ),
      child: Text(
        'No hay contenido disponible en $title por ahora.',
        textAlign: TextAlign.center,
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
    required this.favorites,
    required this.recommended,
    required this.searchResults,
  });

  factory _ExploreViewData.fromController(
    ContentItemsController controller, {
    required Set<String> favoriteContentIds,
    required String fallbackQuery,
    required bool allowMockFallback,
  }) {
    final realItems = controller.items;
    if (realItems.isEmpty && allowMockFallback) {
      return _ExploreViewData._fallback(fallbackQuery);
    }
    if (realItems.isEmpty) {
      return _ExploreViewData(
        courses: [],
        meditations: [],
        events: [],
        audios: [],
        favorites: [],
        recommended: [],
        searchResults: [],
      );
    }

    final visualItems = realItems.asMap().entries.map((entry) {
      return _mapContentItem(
        entry.value,
        entry.key,
        favoriteContentIds: favoriteContentIds,
      );
    }).toList();

    return _ExploreViewData(
      courses: _mapContentItemsByType(realItems, {
        'course',
      }, favoriteContentIds: favoriteContentIds),
      meditations: _mapContentItemsByType(realItems, {
        'meditation',
      }, favoriteContentIds: favoriteContentIds),
      events: const [],
      audios: _mapContentItemsByType(realItems, {
        'audio',
        'sound',
      }, favoriteContentIds: favoriteContentIds),
      favorites: visualItems.where((item) => item.isFavorite).toList(),
      recommended: controller.featuredItems.isEmpty
          ? visualItems.take(8).toList()
          : controller.featuredItems.asMap().entries.map((entry) {
              return _mapContentItem(
                entry.value,
                entry.key,
                favoriteContentIds: favoriteContentIds,
              );
            }).toList(),
      searchResults: visualItems,
    );
  }

  factory _ExploreViewData._fallback(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return _ExploreViewData(
        courses: MockExploreData.courses,
        meditations: MockExploreData.meditations,
        events: MockExploreData.events,
        audios: MockExploreData.audios,
        favorites: _mockFavorites,
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
      favorites: const [],
      recommended: const [],
      searchResults: results,
    );
  }

  final List<ContentItem> courses;
  final List<ContentItem> meditations;
  final List<ContentItem> events;
  final List<ContentItem> audios;
  final List<ContentItem> favorites;
  final List<ContentItem> recommended;
  final List<ContentItem> searchResults;

  bool get hasAnySection =>
      courses.isNotEmpty ||
      meditations.isNotEmpty ||
      events.isNotEmpty ||
      audios.isNotEmpty ||
      favorites.isNotEmpty ||
      recommended.isNotEmpty ||
      searchResults.isNotEmpty;

  List<ContentItem> itemsForCategory(QuickCategoryType type) {
    return switch (type) {
      QuickCategoryType.audios => audios,
      QuickCategoryType.meditations => meditations,
      QuickCategoryType.courses => courses,
      QuickCategoryType.favorites => favorites,
    };
  }

  String titleForCategory(QuickCategoryType type) {
    return switch (type) {
      QuickCategoryType.audios => 'Audio y sonido',
      QuickCategoryType.meditations => 'Meditaciones',
      QuickCategoryType.courses => 'Cursos',
      QuickCategoryType.favorites => 'Favoritos',
    };
  }

  ContentItem get heroItem {
    return courses.isNotEmpty
        ? courses.first
        : recommended.isNotEmpty
        ? recommended.first
        : MockExploreData.courses.first;
  }

  static List<ContentItem> _mapContentItemsByType(
    List<AppContentItem> items,
    Set<String> acceptedTypes, {
    required Set<String> favoriteContentIds,
  }) {
    return items
        .asMap()
        .entries
        .where((entry) {
          return acceptedTypes.contains(_normalizeType(entry.value.tipo));
        })
        .map((entry) {
          return _mapContentItem(
            entry.value,
            entry.key,
            favoriteContentIds: favoriteContentIds,
          );
        })
        .toList();
  }

  static ContentItem _mapContentItem(
    AppContentItem item,
    int index, {
    required Set<String> favoriteContentIds,
  }) {
    return ContentItem(
      uuidContentItem: item.uuidContentItem,
      title: item.titulo,
      type: _displayType(item.tipo),
      duration: _formatDuration(item.duracionSegundos),
      imageAsset: _fallbackAssetForType(item.tipo, index),
      description: item.descripcion ?? item.subtitulo,
      isNew: item.destacado,
      isFavorite: favoriteContentIds.contains(item.uuidContentItem),
    );
  }

  static List<ContentItem> get _mockFavorites {
    return [
      ...MockExploreData.courses,
      ...MockExploreData.meditations,
      ...MockExploreData.events,
      ...MockExploreData.audios,
      ...MockExploreData.recommended,
    ].where((item) => item.isFavorite).toList();
  }

  static String _displayType(String value) {
    return switch (_normalizeType(value)) {
      'course' => 'Curso',
      'meditation' => 'Meditación',
      'event' => 'Evento',
      'sound' => 'Sonido',
      'audio' => 'Audio',
      'session' => 'Sesión',
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
      'course' => const [
        AppAssets.curso1,
        AppAssets.curso2,
        AppAssets.curso3,
        AppAssets.curso4,
        AppAssets.curso5,
        AppAssets.curso6,
        AppAssets.curso7,
        AppAssets.curso8,
      ],
      'meditation' => const [
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
      'event' => const [
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(width: 148),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          hintText: 'Buscar',
          controller: controller,
          prefixIcon: Icons.search_rounded,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          onChanged: (value) {
            if (value.trim().isEmpty) {
              onSubmitted(value);
            }
          },
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
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
        ),
      ],
    );
  }
}
