import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:mobile_flutter/presentation/providers/selection_provider.dart';
import 'package:mobile_flutter/presentation/providers/nearby_providers.dart';
import 'package:mobile_flutter/data/services/purchase_service.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isMultiSelectMode = false;
  final Set<String> _selectedPoiIds = {};
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  static const List<_CategoryItem> _categories = [
    _CategoryItem(id: null, label: 'Все', icon: Icons.apps),
    _CategoryItem(id: 'museum', label: 'Музеи', icon: Icons.museum),
    _CategoryItem(
        id: 'monument', label: 'Памятники', icon: Icons.account_balance),
    _CategoryItem(id: 'park', label: 'Парки', icon: Icons.park),
    _CategoryItem(id: 'church', label: 'Церкви', icon: Icons.church),
    _CategoryItem(id: 'food', label: 'Еда', icon: Icons.restaurant),
    _CategoryItem(id: 'shopping', label: 'Шоппинг', icon: Icons.shopping_bag),
  ];

  @override
  void initState() {
    super.initState();
    final city = ref.read(selectedCityProvider).value;
    if (city != null) {
      ref.read(poiRepositoryProvider).syncPoisForCity(city).ignore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedCityProvider, (prev, next) {
      final city = next.value;
      if (city != null && city != prev?.value) {
        ref.read(poiRepositoryProvider).syncPoisForCity(city).ignore();
      }
    });

    final selectedCity = ref.watch(selectedCityProvider).value;
    if (selectedCity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final poisStream =
        ref.watch(poiRepositoryProvider).watchPoisForCity(selectedCity);
    final selectedIds = ref.watch(selectionProvider);
    final isMultiSelectMode = selectedIds.isNotEmpty || _isMultiSelectMode;

    return Scaffold(
      appBar: _buildAppBar(context, selectedIds),
      body: StreamBuilder<List<Poi>>(
        stream: poisStream,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }

          // Error state
          if (snapshot.hasError) {
            return ErrorStateWidget.generic(
              error: snapshot.error.toString(),
              onRetry: () {
                ref.read(poiRepositoryProvider).syncPoisForCity(selectedCity);
              },
            );
          }

          final pois = snapshot.data ?? [];
          final filteredPois = pois.where((p) {
            final matchesSearch = _searchQuery.isEmpty ||
                p.titleRu.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory = _selectedCategory == null ||
                p.category?.toLowerCase() == _selectedCategory?.toLowerCase();
            return matchesSearch && matchesCategory;
          }).toList();

          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: filteredPois.isEmpty
                    ? _searchQuery.isNotEmpty
                        ? EmptyStateWidget.searchResults(query: _searchQuery)
                        : EmptyStateWidget.pois(
                            onRefresh: () {
                              ref
                                  .read(poiRepositoryProvider)
                                  .syncPoisForCity(selectedCity);
                            },
                          )
                    : RefreshableContent(
                        onRefresh: () async {
                          HapticFeedback.lightImpact();
                          await ref
                              .read(poiRepositoryProvider)
                              .syncPoisForCity(selectedCity);
                        },
                        child: StaggeredListBuilder(
                          itemCount: filteredPois.length,
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            left: context.horizontalPadding,
                            right: context.horizontalPadding,
                            bottom: isMultiSelectMode ? 100 : AppSpacing.xl,
                          ),
                          itemBuilder: (context, index) {
                            return _buildPoiItem(
                                context, filteredPois[index], selectedIds);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          isMultiSelectMode ? _buildBottomBar(context, selectedIds) : null,
      floatingActionButton: !isMultiSelectMode
          ? SafeFloatingActionButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isMultiSelectMode = true);
              },
              tooltip: 'Режим множественного выбора',
              child: const Icon(Icons.checklist),
            )
          : null,
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: EdgeInsets.all(context.horizontalPadding),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SkeletonListTile(hasLeading: true, hasTrailing: true),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, Set<String> selectedIds) {
    if (selectedIds.isNotEmpty || _isMultiSelectMode) {
      return AppBar(
        title: Semantics(
          label: 'Выбрано ${selectedIds.length} мест',
          child: Text('Выбрано: ${selectedIds.length}'),
        ),
        leading: AccessibleIconButton(
          icon: Icons.close,
          tooltip: 'Отменить выбор',
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _isMultiSelectMode = false);
            ref.read(selectionProvider.notifier).clear();
          },
        ),
        actions: [
          AccessibleIconButton(
            icon: Icons.select_all,
            tooltip: 'Выбрать все',
            onPressed: () {
              HapticFeedback.lightImpact();
              // Logic to select visible would go here, for now manual
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Для выбора воспользуйтесь долгим нажатием')),
              );
            },
          ),
        ],
      );
    }

    return ResponsiveAppBar(
      title: 'Каталог',
      actions: [
        AccessibleIconButton(
          icon: Icons.qr_code_scanner,
          tooltip: 'Сканировать QR-код',
          onPressed: () => context.push('/qr_scanner'),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: AppSpacing.sm,
          ),
          child: Semantics(
            label: 'Поиск мест',
            textField: true,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Поиск мест...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        tooltip: 'Очистить поиск',
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 60,
      child: Semantics(
        label: 'Категории мест',
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = _selectedCategory == cat.id;

            return Semantics(
              button: true,
              selected: isSelected,
              label: 'Категория ${cat.label}',
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 16),
                    const SizedBox(width: 4),
                    Text(cat.label),
                  ],
                ),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: colorScheme.primaryContainer,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = cat.id);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPoiItem(BuildContext context, Poi poi, Set<String> selectedIds) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelected = selectedIds.contains(poi.id);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${poi.titleRu}, категория ${_translateCategory(poi.category)}',
      hint: (selectedIds.isNotEmpty || _isMultiSelectMode)
          ? (isSelected
              ? 'Нажмите чтобы убрать из выбора'
              : 'Нажмите чтобы выбрать')
          : 'Нажмите для просмотра',
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (selectedIds.isNotEmpty || _isMultiSelectMode) {
              ref.read(selectionProvider.notifier).toggle(poi.id);
            } else {
              context.push('/poi/${poi.id}');
            }
          },
          onLongPress: !(selectedIds.isNotEmpty || _isMultiSelectMode)
              ? () {
                  HapticFeedback.mediumImpact();
                  setState(() => _isMultiSelectMode = true);
                  ref.read(selectionProvider.notifier).toggle(poi.id);
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(context.cardPadding),
            child: Row(
              children: [
                HeroImage(
                  tag: 'poi-image-${poi.id}',
                  imageUrl: null,
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.circular(12),
                  placeholder: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.3),
                          colorScheme.secondary.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.place,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(
                        poi.titleRu,
                        maxLines: 1,
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      if (poi.category != null)
                        TextBadge(
                          _translateCategory(poi.category),
                          fontSize: 11,
                          backgroundColor:
                              colorScheme.primaryContainer.withOpacity(0.5),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AccessibleIconButton(
                      icon: poi.isFavorite
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      tooltip: poi.isFavorite
                          ? 'Удалить из избранного'
                          : 'Добавить в избранное',
                      color: poi.isFavorite ? colorScheme.primary : null,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(poiRepositoryProvider).toggleFavorite(poi.id);
                      },
                    ),
                    if (selectedIds.isNotEmpty || _isMultiSelectMode)
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          ref.read(selectionProvider.notifier).toggle(poi.id);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Set<String> selectedIds) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final purchaseState = ref.watch(purchaseServiceProvider);
    final isBuying = purchaseState.status == PurchaseStatusState.pending;

    return AnimatedContainer(
      duration: AppDurations.fast,
      padding: EdgeInsets.only(
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        top: AppSpacing.md,
        bottom: bottomPadding + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              enabled: selectedIds.isNotEmpty && !isBuying,
              label: 'Купить ${selectedIds.length} мест',
              child: ElevatedButton.icon(
                onPressed: (selectedIds.isEmpty || isBuying)
                    ? null
                    : () async {
                        HapticFeedback.lightImpact();
                        await ref
                            .read(purchaseServiceProvider.notifier)
                            .buyBatch(selectedIds.toList(), []);

                        // Check result
                        if (context.mounted) {
                          final state = ref.read(purchaseServiceProvider);
                          if (state.status == PurchaseStatusState.restored ||
                              state.status == PurchaseStatusState.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Покупка успешна!')));
                            ref.read(selectionProvider.notifier).clear();
                            setState(() => _isMultiSelectMode = false);
                          } else if (state.status ==
                              PurchaseStatusState.error) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(state.error ?? 'Не удалось купить')));
                          }
                        }
                      },
                icon: isBuying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.shopping_cart_checkout),
                label: Text(isBuying
                    ? 'Обработка...'
                    : 'Купить (${selectedIds.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: selectedIds.isEmpty
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Добавлено ${selectedIds.length} мест в маршрут')),
                    );
                    ref.read(selectionProvider.notifier).clear();
                    setState(() => _isMultiSelectMode = false);
                  },
            icon: const Icon(Icons.playlist_add),
            tooltip: 'В маршрут',
          ),
        ],
      ),
    );
  }

  String _translateCategory(String? category) {
    if (category == null) return 'Место';
    const translations = {
      'museum': 'Музей',
      'monument': 'Памятник',
      'park': 'Парк',
      'church': 'Церковь',
      'castle': 'Замок',
      'historic': 'История',
      'nature': 'Природа',
      'food': 'Еда',
      'shopping': 'Шоппинг',
    };
    return translations[category.toLowerCase()] ?? category;
  }
}

class _CategoryItem {
  final String? id;
  final String label;
  final IconData icon;

  const _CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}
