import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/data/repositories/tour_repository.dart';
import 'package:mobile_flutter/data/repositories/city_repository.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/domain/entities/city.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:mobile_flutter/presentation/providers/selection_provider.dart';
import 'package:mobile_flutter/data/services/purchase_service.dart';


class ToursListScreen extends ConsumerStatefulWidget {
  const ToursListScreen({super.key});

  @override
  ConsumerState<ToursListScreen> createState() => _ToursListScreenState();
}

class _ToursListScreenState extends ConsumerState<ToursListScreen> {
  String _searchQuery = '';
  String? _selectedFilter;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isMultiSelectMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider).value;

    if (selectedCity == null) {
      return const Scaffold(
        body: Center(
          child: SkeletonTourDetail(),
        ),
      );
    }

    final toursStream = ref.watch(tourRepositoryProvider).watchTours(selectedCity);
    final selectedIds = ref.watch(selectionProvider);
    final isMultiSelectMode = selectedIds.isNotEmpty || _isMultiSelectMode;

    // Получаем название города
    final citiesStream = ref.watch(cityRepositoryProvider).watchCities();

    return StreamBuilder<List<City>>(
      stream: citiesStream,
      builder: (context, citiesSnapshot) {
        // Определяем название города
        String cityName = 'Город';
        final cities = citiesSnapshot.data ?? [];
        final currentCity = cities.where((c) => c.slug == selectedCity).firstOrNull;
        if (currentCity != null) {
          cityName = currentCity.nameRu;
        } else {
          // Fallback для старых slug
          if (selectedCity == 'kaliningrad_city') {
            cityName = 'Калининград';
          } else if (selectedCity == 'kaliningrad_oblast') {
            cityName = 'Калининградская область';
          }
        }

        return Scaffold(
          appBar: _buildAppBar(context, selectedCity, selectedIds, cityName),
          body: StreamBuilder<List<Tour>>(
        stream: toursStream,
        builder: (context, snapshot) {
          // Loading state with skeleton
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }

          // Error state
          if (snapshot.hasError) {
            return RefreshableContent(
              onRefresh: () async {
                // Trigger refresh
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: ErrorStateWidget.generic(
                    error: snapshot.error.toString(),
                    onRetry: () => setState(() {}),
                  ),
                ),
              ),
            );
          }

          var tours = snapshot.data ?? [];

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            tours = tours.where((t) => 
              t.titleRu.toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();
          }

          // Apply type filters
          if (_selectedFilter == 'short') {
            tours = tours.where((t) => (t.durationMinutes ?? 0) < 60).toList();
          } else if (_selectedFilter == 'walking') {
            tours = tours.where((t) => t.transportType == 'walking').toList();
          } else if (_selectedFilter == 'driving') {
            tours = tours.where((t) => t.transportType == 'driving').toList();
          }

          // Empty state
          if (tours.isEmpty) {
            if (_searchQuery.isNotEmpty) {
              return EmptyStateWidget.searchResults(query: _searchQuery);
            }
            return EmptyStateWidget.tours(
              onRefresh: () => setState(() {}),
            );
          }

          // Tour list with staggered animation
          return RefreshableContent(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              setState(() {});
            },
            child: StaggeredListBuilder(
              itemCount: tours.length,
              padding: EdgeInsets.only(
                left: context.horizontalPadding,
                right: context.horizontalPadding,
                bottom: isMultiSelectMode ? 100 : AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                return _TourCard(
                  tour: tours[index],
                  isSelected: selectedIds.contains(tours[index].id),
                  isSelectionMode: isMultiSelectMode,
                  onToggle: () {
                    ref.read(selectionProvider.notifier).toggle(tours[index].id);
                    if (!isMultiSelectMode) {
                        setState(() => _isMultiSelectMode = true);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: isMultiSelectMode ? _buildBottomBar(context, selectedIds) : null,
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
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String selectedCity, Set<String> selectedIds, String cityName) {
    if (selectedIds.isNotEmpty || _isMultiSelectMode) {
       return AppBar(
        title: Text('Выбрано: ${selectedIds.length}'),
        leading: AccessibleIconButton(
          icon: Icons.close,
          tooltip: 'Отменить выбор',
          onPressed: () {
             setState(() => _isMultiSelectMode = false);
             ref.read(selectionProvider.notifier).clear();
          },
        ),
        actions: [
          AccessibleIconButton(
            icon: Icons.select_all,
            tooltip: 'Выбрать все',
            onPressed: () {
               // Logic to select all visible
            },
          )
        ],
       );
    }
  
    return ResponsiveAppBar(
        title: 'Туры: $cityName',
        actions: [
          AccessibleIconButton(
            icon: Icons.qr_code_scanner,
            tooltip: 'Сканировать QR-код',
            onPressed: () => context.push('/qr_scanner'),
          ),
          AccessibleIconButton(
            icon: Icons.download_for_offline_outlined,
            tooltip: 'Оффлайн режим',
            onPressed: () => context.push('/offline-manager'),
          ),
          AccessibleIconButton(
            icon: Icons.swap_horiz,
            tooltip: 'Сменить город',
            onPressed: () => ref.read(selectedCityProvider.notifier).clear(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: [
                // Search field
                Semantics(
                  label: 'Поиск туров',
                  hint: 'Введите название тура для поиска',
                  textField: true,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Поиск туров...',
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
                const SizedBox(height: AppSpacing.sm),
                
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Semantics(
                    label: 'Фильтры туров',
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Все',
                          isSelected: _selectedFilter == null,
                          onTap: () => setState(() => _selectedFilter = null),
                        ),
                        _FilterChip(
                          label: 'Пешие',
                          icon: Icons.directions_walk,
                          isSelected: _selectedFilter == 'walking',
                          onTap: () => setState(() => _selectedFilter = 'walking'),
                        ),
                        _FilterChip(
                          label: 'Автомобильные',
                          icon: Icons.directions_car,
                          isSelected: _selectedFilter == 'driving',
                          onTap: () => setState(() => _selectedFilter = 'driving'),
                        ),
                        _FilterChip(
                          label: 'Короткие',
                          icon: Icons.timer_outlined,
                          isSelected: _selectedFilter == 'short',
                          onTap: () => setState(() => _selectedFilter = 'short'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
            child: ElevatedButton.icon(
                onPressed: (selectedIds.isEmpty || isBuying)
                    ? null
                    : () async {
                        HapticFeedback.lightImpact();
                        await ref.read(purchaseServiceProvider.notifier).buyBatch([], selectedIds.toList());
                        
                        // Check result
                        if (context.mounted) {
                           final state = ref.read(purchaseServiceProvider);
                            if (state.status == PurchaseStatusState.restored || state.status == PurchaseStatusState.success) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Покупка успешна!')));
                                ref.read(selectionProvider.notifier).clear();
                                setState(() => _isMultiSelectMode = false);
                           } else if (state.status == PurchaseStatusState.error) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error ?? 'Не удалось купить')));
                           }
                        }
                      },
                icon: isBuying 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.shopping_cart_checkout),
                label: Text(isBuying ? 'Обработка...' : 'Купить (${selectedIds.length})'),
                style: ElevatedButton.styleFrom(
                   backgroundColor: colorScheme.primary,
                   foregroundColor: colorScheme.onPrimary,
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: EdgeInsets.all(context.horizontalPadding),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) => const SkeletonTourCard(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label фильтр',
        child: FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16),
                const SizedBox(width: 4),
              ],
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (_) {
            HapticFeedback.selectionClick();
            onTap();
          },
          showCheckmark: false,
          selectedColor: colorScheme.primaryContainer,
          backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final Tour tour;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onToggle;

  const _TourCard({
    required this.tour,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Build semantic label for screen readers
    final semanticParts = <String>[
      'Тур: ${tour.titleRu}',
      if (tour.durationMinutes != null) '${tour.durationMinutes} минут',
      if (tour.distanceKm != null) '${tour.distanceKm} километров',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        button: true,
        label: semanticParts.join(', '),
        hint: 'Нажмите для просмотра деталей тура',
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
               if (isSelectionMode) {
                 onToggle();
               } else {
                 HapticFeedback.lightImpact();
                 context.push('/tour/${tour.id}');
               }
            },
            onLongPress: !isSelectionMode ? () {
               HapticFeedback.mediumImpact();
               onToggle();
            } : null,
            child: Stack(
              children: [
                Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image with hero animation
                  HeroImage(
                    tag: 'tour-image-${tour.id}',
                    imageUrl: tour.coverImage,
                    height: context.responsive(
                      smallPhone: 140.0,
                      phone: 160.0,
                      tablet: 200.0,
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: EdgeInsets.all(context.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TitleText(
                                tour.titleRu,
                                maxLines: 2,
                                style: textTheme.titleMedium,
                              ),
                            ),
                            if (tour.durationMinutes != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              TextBadge.duration(tour.durationMinutes!),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Description
                        BodyText(
                          tour.descriptionRu ?? 'Увлекательный маршрут по знаковым местам региона.',
                          maxLines: 2,
                        ),
                        
                        const SizedBox(height: AppSpacing.sm),
                        
                        // Metadata row
                        Row(
                          children: [
                            if (tour.distanceKm != null) ...[
                              TextBadge.distance(tour.distanceKm!),
                              const SizedBox(width: AppSpacing.sm),
                            ],
                            if (tour.transportType != null) ...[
                              Icon(
                                tour.transportType == 'walking' 
                                    ? Icons.directions_walk 
                                    : Icons.directions_car,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              LabelText(
                                tour.transportType == 'walking' ? 'Пешком' : 'На машине',
                              ),
                            ],
                            const Spacer(),
                            if (!isSelectionMode)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelectionMode)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Checkbox(
                       value: isSelected,
                       onChanged: (v) => onToggle(),
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
