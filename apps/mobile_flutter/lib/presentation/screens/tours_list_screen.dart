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
import 'package:mobile_flutter/presentation/widgets/common/glass_widgets.dart';
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
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: const Center(
          child: SkeletonTourDetail(),
        ),
      );
    }

    final toursStream =
        ref.watch(tourRepositoryProvider).watchTours(selectedCity);
    final selectedIds = ref.watch(selectionProvider);
    final isMultiSelectMode = selectedIds.isNotEmpty || _isMultiSelectMode;

    final citiesStream = ref.watch(cityRepositoryProvider).watchCities();

    return StreamBuilder<List<City>>(
      stream: citiesStream,
      builder: (context, citiesSnapshot) {
        String cityName = 'Город';
        final cities = citiesSnapshot.data ?? [];
        final currentCity =
            cities.where((c) => c.slug == selectedCity).firstOrNull;
        if (currentCity != null) {
          cityName = currentCity.nameRu;
        } else {
          if (selectedCity == 'kaliningrad_city') {
            cityName = 'Калининград';
          } else if (selectedCity == 'kaliningrad_oblast') {
            cityName = 'Калининградская область';
          }
        }

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: StreamBuilder<List<Tour>>(
            stream: toursStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingSkeleton();
              }

              if (snapshot.hasError) {
                return RefreshableContent(
                  onRefresh: () async {
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
                tours = tours
                    .where((t) => t.titleRu
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();
              }

              // Apply type filters
              if (_selectedFilter == 'short') {
                tours =
                    tours.where((t) => (t.durationMinutes ?? 0) < 60).toList();
              } else if (_selectedFilter == 'walking') {
                tours = tours.where((t) => t.tourType == 'walking').toList();
              } else if (_selectedFilter == 'driving') {
                tours = tours.where((t) => t.tourType == 'driving').toList();
              }

              if (tours.isEmpty) {
                if (_searchQuery.isNotEmpty) {
                  return EmptyStateWidget.searchResults(query: _searchQuery);
                }
                return EmptyStateWidget.tours(
                  onRefresh: () => setState(() {}),
                );
              }

              // Separate featured tours (first 3 with images)
              final featuredTours = tours.take(3).toList();
              final regularTours = tours.skip(3).toList();

              return RefreshableContent(
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  setState(() {});
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Custom header
                    SliverToBoxAdapter(
                      child: _buildHeader(context, cityName, selectedIds),
                    ),

                    // Search bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.horizontalPadding,
                          vertical: AppSpacing.sm,
                        ),
                        child: GlassSearchBar(
                          controller: _searchController,
                          hintText: 'Поиск экскурсий...',
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.textTertiary),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),

                    // Filter chips
                    SliverToBoxAdapter(
                      child: _buildFilterChips(),
                    ),

                    // Featured section (horizontal scroll)
                    if (featuredTours.isNotEmpty && _searchQuery.isEmpty) ...[
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'Популярные',
                          actionText: 'Все',
                          onActionTap: () {},
                          padding: EdgeInsets.only(
                            left: context.horizontalPadding,
                            right: context.horizontalPadding,
                            top: AppSpacing.md,
                            bottom: AppSpacing.sm,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                                horizontal: context.horizontalPadding),
                            itemCount: featuredTours.length,
                            itemBuilder: (context, index) {
                              return _FeaturedTourCard(
                                tour: featuredTours[index],
                                isFirst: index == 0,
                                isLast: index == featuredTours.length - 1,
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    // All tours section
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: _searchQuery.isNotEmpty
                            ? 'Результаты поиска'
                            : 'Все экскурсии',
                        padding: EdgeInsets.only(
                          left: context.horizontalPadding,
                          right: context.horizontalPadding,
                          top: AppSpacing.lg,
                          bottom: AppSpacing.sm,
                        ),
                      ),
                    ),

                    // Tour list
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: context.horizontalPadding,
                        right: context.horizontalPadding,
                        bottom: isMultiSelectMode ? 100 : AppSpacing.xxl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final tour = _searchQuery.isNotEmpty
                                ? tours[index]
                                : (regularTours.isNotEmpty
                                    ? regularTours[index]
                                    : tours[index]);
                            return _TourCard(
                              tour: tour,
                              isSelected: selectedIds.contains(tour.id),
                              isSelectionMode: isMultiSelectMode,
                              onToggle: () {
                                ref
                                    .read(selectionProvider.notifier)
                                    .toggle(tour.id);
                                if (!isMultiSelectMode) {
                                  setState(() => _isMultiSelectMode = true);
                                }
                              },
                            );
                          },
                          childCount: _searchQuery.isNotEmpty
                              ? tours.length
                              : (regularTours.isNotEmpty
                                  ? regularTours.length
                                  : tours.length),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar:
              isMultiSelectMode ? _buildBottomBar(context, selectedIds) : null,
          floatingActionButton: !isMultiSelectMode
              ? GlassFAB(
                  icon: Icons.checklist,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isMultiSelectMode = true);
                  },
                  tooltip: 'Режим множественного выбора',
                  isPrimary: false,
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, String cityName, Set<String> selectedIds) {
    final safeTop = MediaQuery.of(context).padding.top;

    if (selectedIds.isNotEmpty || _isMultiSelectMode) {
      return Container(
        padding: EdgeInsets.only(
          top: safeTop + AppSpacing.sm,
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () {
                setState(() => _isMultiSelectMode = false);
                ref.read(selectionProvider.notifier).clear();
              },
            ),
            Text(
              'Выбрано: ${selectedIds.length}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.select_all, color: AppColors.textPrimary),
              onPressed: () {},
              tooltip: 'Выбрать все',
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        top: safeTop + AppSpacing.md,
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Экскурсии',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cityName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.qr_code_scanner,
            onPressed: () => context.push('/qr_scanner'),
            tooltip: 'Сканировать QR',
          ),
          _HeaderIconButton(
            icon: Icons.download_for_offline_outlined,
            onPressed: () => context.push('/offline-manager'),
            tooltip: 'Оффлайн',
          ),
          _HeaderIconButton(
            icon: Icons.swap_horiz,
            onPressed: () => ref.read(selectedCityProvider.notifier).clear(),
            tooltip: 'Сменить город',
          ),
          _HeaderIconButton(
            icon: Icons.settings_outlined,
            onPressed: () => context.push('/settings'),
            tooltip: 'Настройки',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalPadding,
        vertical: AppSpacing.sm,
      ),
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
    );
  }

  Widget _buildBottomBar(BuildContext context, Set<String> selectedIds) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final purchaseState = ref.watch(purchaseServiceProvider);
    final isBuying = purchaseState.status == PurchaseStatusState.pending;

    return Container(
      padding: EdgeInsets.only(
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        top: AppSpacing.md,
        bottom: bottomPadding + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: PrimaryCTAButton(
        text: isBuying ? 'Обработка...' : 'Купить (${selectedIds.length})',
        icon: isBuying ? null : Icons.shopping_cart_checkout,
        isLoading: isBuying,
        onPressed: selectedIds.isEmpty
            ? () {}
            : () async {
                HapticFeedback.lightImpact();
                await ref
                    .read(purchaseServiceProvider.notifier)
                    .buyBatch([], selectedIds.toList());

                if (context.mounted) {
                  final state = ref.read(purchaseServiceProvider);
                  if (state.status == PurchaseStatusState.restored ||
                      state.status == PurchaseStatusState.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Покупка успешна!')));
                    ref.read(selectionProvider.notifier).clear();
                    setState(() => _isMultiSelectMode = false);
                  } else if (state.status == PurchaseStatusState.error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(state.error ?? 'Не удалось купить')));
                  }
                }
              },
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

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: IconButton(
        icon: Icon(icon, color: AppColors.textSecondary, size: 22),
        onPressed: onPressed,
        tooltip: tooltip,
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
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label фильтр',
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentPrimary.withOpacity(0.15)
                  : AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentPrimary.withOpacity(0.3)
                    : AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? AppColors.accentPrimary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.accentPrimary
                        : AppColors.textSecondary,
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

class _FeaturedTourCard extends StatelessWidget {
  final Tour tour;
  final bool isFirst;
  final bool isLast;

  const _FeaturedTourCard({
    required this.tour,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: isLast ? 0 : AppSpacing.md,
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/tour/${tour.id}');
        },
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.card,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                HeroImage(
                  tag: 'tour-featured-${tour.id}',
                  imageUrl: tour.coverImage,
                  height: 220,
                  fit: BoxFit.cover,
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges row
                      Row(
                        children: [
                          if (tour.isFree)
                            const GlassBadge(
                              text: 'Бесплатно',
                              textColor: AppColors.accentPrimary,
                            )
                          else if (tour.priceAmount != null)
                            GlassBadge(
                              text: '${tour.priceAmount?.toInt()} ₽',
                              textColor: AppColors.accentPrimary,
                            ),
                          const Spacer(),
                          if (tour.avgRating != null)
                            GlassBadge(
                              text: tour.avgRating!.toStringAsFixed(1),
                              icon: Icons.star,
                              textColor: AppColors.warning,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        tour.titleRu,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Meta info
                      Row(
                        children: [
                          if (tour.durationMinutes != null) ...[
                            const Icon(Icons.schedule,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${tour.durationMinutes} мин',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (tour.distanceKm != null) ...[
                            const Icon(Icons.straighten,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${tour.distanceKm} км',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
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
        child: GlassCard(
          onTap: () {
            if (isSelectionMode) {
              onToggle();
            } else {
              HapticFeedback.lightImpact();
              context.push('/tour/${tour.id}');
            }
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image with gradient overlay
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.card),
                    ),
                    child: GradientOverlay(
                      child: HeroImage(
                        tag: 'tour-image-${tour.id}',
                        imageUrl: tour.coverImage,
                        height: context.responsive(
                          smallPhone: 140.0,
                          phone: 160.0,
                          tablet: 200.0,
                        ),
                      ),
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
                              child: Text(
                                tour.titleRu,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (tour.avgRating != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              GlassBadge(
                                text: tour.avgRating!.toStringAsFixed(1),
                                icon: Icons.star,
                                textColor: AppColors.warning,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Description
                        Text(
                          tour.descriptionRu ??
                              'Увлекательный маршрут по знаковым местам региона.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Metadata row
                        Row(
                          children: [
                            if (tour.durationMinutes != null) ...[
                              _MetaItem(
                                icon: Icons.schedule,
                                text: '${tour.durationMinutes} мин',
                              ),
                              const SizedBox(width: AppSpacing.md),
                            ],
                            if (tour.distanceKm != null) ...[
                              _MetaItem(
                                icon: Icons.straighten,
                                text: '${tour.distanceKm} км',
                              ),
                              const SizedBox(width: AppSpacing.md),
                            ],
                            const Spacer(),
                            if (tour.isFree)
                              const Text(
                                'Бесплатно',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentPrimary,
                                ),
                              )
                            else if (tour.priceAmount != null)
                              Text(
                                '${tour.priceAmount?.toInt()} ₽',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accentPrimary,
                                ),
                              ),
                            if (!isSelectionMode) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelectionMode)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.glassBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (v) => onToggle(),
                      activeColor: AppColors.accentPrimary,
                      checkColor: Colors.white,
                      side: const BorderSide(color: AppColors.textTertiary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
