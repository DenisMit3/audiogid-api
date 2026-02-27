import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audio_service/audio_service.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/data/repositories/entitlement_repository.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/presentation/providers/nearby_providers.dart';
import 'package:mobile_flutter/presentation/widgets/paywall_widget.dart';
import 'package:mobile_flutter/core/audio/audio_player_service.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_flutter/data/repositories/itinerary_repository.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';

class PoiDetailScreen extends ConsumerStatefulWidget {
  final String poiId;

  const PoiDetailScreen({super.key, required this.poiId});

  @override
  ConsumerState<PoiDetailScreen> createState() => _PoiDetailScreenState();
}

class _PoiDetailScreenState extends ConsumerState<PoiDetailScreen> {
  bool _autoPlayProcessed = false;

  @override
  void initState() {
    super.initState();
    _syncData();
  }

  Future<void> _syncData() async {
    // Performance tracing removed
    try {
      final selectedCity = ref.read(selectedCityProvider).value;
      if (selectedCity != null) {
        await ref
            .read(poiRepositoryProvider)
            .syncPoi(widget.poiId, selectedCity);
      }
    } finally {
      // trace.stop() removed
    }
  }

  @override
  Widget build(BuildContext context) {
    final poiStream = ref.read(poiRepositoryProvider).watchPoi(widget.poiId);
    final grantsAsync = ref.watch(entitlementGrantsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<Poi?>(
      stream: poiStream,
      builder: (context, snapshot) {
        // Loading state with skeleton
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const SkeletonPoiDetail(),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorStateWidget.generic(
              error: snapshot.error,
              onRetry: () => setState(() {}),
            ),
          );
        }

        final poi = snapshot.data;

        // Not found state
        if (poi == null) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorStateWidget.notFound(item: 'Достопримечательность'),
          );
        }

        final grants = grantsAsync.value ?? [];
        final hasAccess = poi.hasAccess ||
            grants.any((g) =>
                g.isActive && g.scope == 'city' && g.ref == poi.citySlug);

        // Auto-play handling
        if (!_autoPlayProcessed) {
          final extra =
              GoRouterState.of(context).extra as Map<String, dynamic>?;
          if (extra != null && extra['autoplay'] == true) {
            if (hasAccess && poi.narrations.isNotEmpty) {
              _autoPlayProcessed = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _playAudio(poi);
              });
            }
          }
        }

        return Scaffold(
          body: RefreshableContent(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await _syncData();
            },
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, poi),
                SliverToBoxAdapter(
                  child: ResponsivePadding(
                    child: ResponsiveContainer(
                      padding: EdgeInsets.all(context.horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, poi),
                          const SizedBox(height: AppSpacing.lg),
                          _buildActionButtons(context, poi, hasAccess),
                          const SizedBox(height: AppSpacing.lg),
                          _buildDescription(context, poi),
                          if (hasAccess) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _buildTranscript(context, poi),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          _buildMediaAndSources(context, poi),
                          // Bottom safe area padding
                          SizedBox(
                              height: context.safeAreaPadding.bottom +
                                  AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Poi poi) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = poi.media.where((m) => m.mediaType == 'image').toList();

    return SliverAppBar(
      expandedHeight: context.responsive(
        smallPhone: 240.0,
        phone: 280.0,
        tablet: 350.0,
      ),
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Semantics(
          image: true,
          label: 'Фотография: ${poi.titleRu}',
          child: images.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.6),
                        colorScheme.secondary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.place,
                      size: 80,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: images[index].url,
                          fit: BoxFit.cover,
                          memCacheWidth: 800,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceVariant,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.broken_image,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                    // Image count indicator
                    if (images.length > 1)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${images.length} фото',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
      actions: [
        AccessibleIconButton(
          icon: poi.isFavorite ? Icons.bookmark : Icons.bookmark_border,
          tooltip:
              poi.isFavorite ? 'Удалить из избранного' : 'Добавить в избранное',
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(poiRepositoryProvider).toggleFavorite(poi.id);
          },
          color: poi.isFavorite ? colorScheme.primary : null,
        ),
        AccessibleIconButton(
          icon: Icons.share_outlined,
          tooltip: 'Поделиться',
          onPressed: () {
            HapticFeedback.lightImpact();
            Share.share(
                'Посмотри ${poi.titleRu} в приложении Аудиогид!\nhttps://audiogid.app/dl/poi/${poi.id}',
                subject: poi.titleRu);
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Poi poi) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (poi.category != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: TextBadge(
                _translateCategory(poi.category!),
                backgroundColor: colorScheme.primaryContainer,
                textColor: colorScheme.onPrimaryContainer,
              ),
            ),
          AccessibleHeader(
            text: poi.titleRu,
            level: 1,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Poi poi, bool hasAccess) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Действия',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: hasAccess
                      ? 'Слушать аудиогид'
                      : 'Слушать (требуется покупка)',
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (!hasAccess) {
                        _showGatingDialog(context);
                      } else {
                        _playAudio(poi);
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Слушать'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Слушать бесплатное превью',
                  child: OutlinedButton.icon(
                    onPressed: poi.previewAudioUrl != null
                        ? () {
                            HapticFeedback.lightImpact();
                            _playPreviewAudio(context, ref, poi.previewAudioUrl!);
                          }
                        : null,
                    icon: const Icon(Icons.preview_outlined),
                    label: Text(poi.previewAudioUrl != null ? 'Превью' : 'Нет превью'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Скачать для офлайн-доступа',
                  child: TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (!hasAccess) {
                        _showGatingDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Добавлено в очередь загрузки'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Скачать'),
                  ),
                ),
              ),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  final itineraryIdsAsync = ref.watch(itineraryIdsProvider);
                  final ids = itineraryIdsAsync.value ?? [];
                  final isInItinerary = ids.contains(poi.id);

                  return Semantics(
                    button: true,
                    label: isInItinerary
                        ? 'Удалить из маршрута'
                        : 'Добавить в маршрут',
                    child: TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (isInItinerary) {
                          ref
                              .read(itineraryIdsProvider.notifier)
                              .remove(poi.id);
                          ref.read(analyticsServiceProvider).logEvent(
                              'remove_from_itinerary', {'poi_id': poi.id});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Удалено из маршрута')),
                          );
                        } else {
                          ref.read(itineraryIdsProvider.notifier).add(poi.id);
                          ref
                              .read(analyticsServiceProvider)
                              .logEvent('add_to_itinerary', {'poi_id': poi.id});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Добавлено в маршрут'),
                              action: SnackBarAction(
                                label: 'Открыть',
                                onPressed: () => context.push('/itinerary'),
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(isInItinerary
                          ? Icons.playlist_add_check
                          : Icons.playlist_add_outlined),
                      label: Text(isInItinerary ? 'В маршруте' : 'В маршрут'),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Poi poi) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccessibleHeader(
          text: 'О месте',
          level: 2,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        ExpandableText(
          poi.descriptionRu ?? 'Описание отсутствует.',
          collapsedMaxLines: 4,
          style: textTheme.bodyLarge?.copyWith(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildTranscript(BuildContext context, Poi poi) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final narration = poi.narrations.isNotEmpty ? poi.narrations.first : null;

    if (narration?.transcript == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        AccessibleHeader(
          text: 'Транскрипт',
          level: 2,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpandableText(
            narration!.transcript!,
            collapsedMaxLines: 6,
            style: textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaAndSources(BuildContext context, Poi poi) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (poi.media.isNotEmpty) ...[
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          AccessibleHeader(
            text: 'Медиа и лицензии',
            level: 2,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...poi.media.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      Icons.copyright_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: LabelText(
                        '${m.author ?? 'Неизвестно'} (${m.licenseType ?? 'CC BY-SA'})',
                      ),
                    ),
                  ],
                ),
              )),
        ],
        if (poi.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          AccessibleHeader(
            text: 'Источники',
            level: 2,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: poi.sources
                .map((s) => Semantics(
                      link: true,
                      label: 'Источник: ${s.name}',
                      child: InkWell(
                        onTap: () {
                          // Open URL
                          HapticFeedback.lightImpact();
                          if (s.url != null) {
                            launchUrl(Uri.parse(s.url!),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.link,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                s.name,
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
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
      'architecture': 'Архитектура',
    };
    return translations[category.toLowerCase()] ?? category;
  }

  void _playAudio(Poi poi) {
    // Create a temporary TourItemEntity for single POI playback
    final tempItem = TourItemEntity(
      id: 'temp_${poi.id}',
      tourId: 'single_poi',
      poiId: poi.id,
      orderIndex: 0,
      poi: poi,
    );
    ref
        .read(audioPlayerServiceProvider)
        .loadPlaylist(
          tourId: 'single_poi',
          items: [tempItem],
          initialIndex: 0,
        )
        .then((_) {
      ref.read(audioPlayerServiceProvider).play();
    });
  }

  void _playPreviewAudio(BuildContext context, WidgetRef ref, String previewUrl) {
    final audioHandler = ref.read(audioHandlerProvider);
    
    // Create a MediaItem for the preview
    final previewItem = MediaItem(
      id: previewUrl,
      title: 'Превью',
      artist: 'Аудиогид',
      duration: const Duration(seconds: 30),
    );
    
    // Play the preview
    audioHandler.updateQueue([previewItem]);
    audioHandler.skipToQueueItem(0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Воспроизведение превью (30 сек)...'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showGatingDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const PaywallWidget(),
    );
  }
}
