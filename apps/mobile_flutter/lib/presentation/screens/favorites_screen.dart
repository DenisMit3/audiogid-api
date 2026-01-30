import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/domain/repositories/poi_repository.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesStream = ref.watch(poiRepositoryProvider).watchFavorites();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ResponsiveAppBar(
        title: 'Избранное',
        actions: [
          AccessibleIconButton(
            icon: Icons.qr_code_scanner,
            tooltip: 'Сканировать QR-код',
            onPressed: () => context.push('/qr_scanner'),
          ),
        ],
      ),
      body: StreamBuilder<List<Poi>>(
        stream: favoritesStream,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(context.horizontalPadding),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) => const SkeletonListTile(
                  hasLeading: true,
                  hasTrailing: true,
                ),
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return ErrorStateWidget.generic(
              message: snapshot.error.toString(),
              onRetry: () {
                // Trigger refresh by rebuilding
              },
            );
          }

          final pois = snapshot.data ?? [];

          // Empty state
          if (pois.isEmpty) {
            return EmptyStateWidget.favorites(
              onExplore: () => context.go('/catalog'),
            );
          }

          // Favorites list
          return RefreshableContent(
            onRefresh: () async {
              HapticFeedback.lightImpact();
            },
            child: StaggeredListBuilder(
              itemCount: pois.length,
              padding: EdgeInsets.all(context.horizontalPadding),
              itemBuilder: (context, index) {
                final poi = pois[index];
                return _FavoriteCard(
                  poi: poi,
                  onRemove: () {
                    HapticFeedback.lightImpact();
                    ref.read(poiRepositoryProvider).toggleFavorite(poi.id);
                    
                    // Show undo snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${poi.titleRu} удалено из избранного'),
                        action: SnackBarAction(
                          label: 'Отменить',
                          onPressed: () {
                            ref.read(poiRepositoryProvider).toggleFavorite(poi.id);
                          },
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Poi poi;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.poi,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: 'Избранное место: ${poi.titleRu}',
      hint: 'Нажмите для просмотра деталей',
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Dismissible(
          key: Key('favorite-${poi.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.delete_outline,
              color: colorScheme.error,
            ),
          ),
          confirmDismiss: (_) async {
            onRemove();
            return false; // Don't dismiss, let the stream update handle it
          },
          child: Card(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/poi/${poi.id}');
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(context.cardPadding),
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: HeroImage(
                        tag: 'poi-image-${poi.id}',
                        imageUrl: null, // TODO: Add POI image
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
                    ),
                    
                    const SizedBox(width: AppSpacing.md),
                    
                    // Content
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
                          Row(
                            children: [
                              if (poi.category != null) ...[
                                TextBadge(
                                  _translateCategory(poi.category!),
                                  fontSize: 11,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Remove button
                    AccessibleIconButton(
                      icon: Icons.bookmark,
                      tooltip: 'Удалить из избранного',
                      onPressed: onRemove,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _translateCategory(String category) {
    const translations = {
      'museum': 'Музей',
      'monument': 'Памятник',
      'park': 'Парк',
      'church': 'Церковь',
      'castle': 'Замок',
      'historic': 'История',
      'nature': 'Природа',
    };
    return translations[category.toLowerCase()] ?? category;
  }
}
