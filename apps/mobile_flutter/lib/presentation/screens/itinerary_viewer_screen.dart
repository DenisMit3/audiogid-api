import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/itinerary_repository.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/data/services/tour_mode_service.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';

class ItineraryViewerScreen extends ConsumerStatefulWidget {
  final String itineraryId;
  const ItineraryViewerScreen({super.key, required this.itineraryId});

  @override
  ConsumerState<ItineraryViewerScreen> createState() =>
      _ItineraryViewerScreenState();
}

class _ItineraryViewerScreenState extends ConsumerState<ItineraryViewerScreen> {
  late Future<Map<String, dynamic>> _itineraryFuture;

  @override
  void initState() {
    super.initState();
    _itineraryFuture = ref
        .read(itineraryRepositoryProvider.future)
        .then((repo) => repo.getItinerary(widget.itineraryId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Маршрут'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _itineraryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorStateWidget.generic(
                error: snapshot.error,
                onRetry: () {
                  setState(() {
                    _itineraryFuture = ref
                        .read(itineraryRepositoryProvider.future)
                        .then((repo) => repo.getItinerary(widget.itineraryId));
                  });
                });
          }

          final data = snapshot.data!;
          final items = (data['items'] as List?) ?? [];
          final title = data['title'] as String? ?? 'Без названия';

          if (items.isEmpty) {
            return const Center(
                child: Text('Этот маршрут пуст или недоступен.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final poiData = item['poi'];
                    if (poiData == null) return const SizedBox.shrink();

                    // Minimal POI display
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorScheme.surfaceVariant,
                          image: (poiData['cover_image'] != null)
                              ? DecorationImage(
                                  image: NetworkImage(poiData['cover_image']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: poiData['cover_image'] == null
                            ? const Icon(Icons.place)
                            : null,
                      ),
                      title: Text(poiData['title_ru'] ?? 'POI'),
                      subtitle: Text(poiData['category'] ?? 'Место'),
                      trailing: Text('${index + 1}',
                          style: Theme.of(context).textTheme.bodyLarge),
                    );
                  },
                ),
              ),
              SafeAreaWrapper(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _startTour(data),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Начать прогулку'),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _startTour(Map<String, dynamic> initialData) async {
    try {
      final repo = await ref.read(itineraryRepositoryProvider.future);
      final manifest = await repo.getItineraryManifest(initialData['id']);

      // Save to local DB to ensure persistance for the tour session
      await repo.saveToDb(manifest);

      // Construct Tour entity from Manifest
      final tourData = manifest['tour'];
      final itemsData = manifest['pois'] as List;

      final tourItems = itemsData.map<TourItemEntity>((item) {
        // We use the data from manifest which mimics the structure needed
        final poi = Poi(
          id: item['id'],
          citySlug: tourData['city_slug'],
          titleRu: item['title_ru'],
          lat: item['lat'],
          lon: item['lon'],
          descriptionRu: item['description_ru'],
          category: 'Itinerary POI', // default
          narrations: [], // Audio URLs are in 'assets' list in manifest, separate from POIs list in the 'tour' part of manifest
          media: [],
          hasAccess: true,
          sources: [],
        );
        return TourItemEntity(
            id: 'item_${poi.id}',
            tourId: tourData['id'],
            poiId: poi.id,
            orderIndex: item['order_index'],
            poi: poi);
      }).toList();

      // Pass 'assets' to tour mode service?
      // TourModeService usually expects POIs to have narrations inside them.
      // The Manifest format from `get_tour_manifest` returns `assets` list separate.
      // I need to map assets back to POIs if I want them to play.

      final assets = manifest['assets'] as List;

      // Mapping with Assets
      final tourItemsWithAudio = itemsData.map<TourItemEntity>((item) {
        final poiId = item['id'];
        final poiAssets = assets
            .where((a) => a['owner_id'] == poiId && a['type'] == 'audio')
            .toList();
        final narrations = poiAssets
            .map((a) => Narration(
                  id: 'audio_$poiId',
                  url: a['url'],
                  locale: a['locale'] ?? 'ru',
                  durationSeconds: (a['duration'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList();

        final poi = Poi(
          id: poiId,
          citySlug: tourData['city_slug'],
          titleRu: item['title_ru'],
          lat: item['lat'],
          lon: item['lon'],
          descriptionRu: item['description_ru'],
          category: 'Itinerary POI',
          narrations: narrations,
          media: [],
          hasAccess: true,
          sources: [],
        );
        return TourItemEntity(
            id: 'item_${poi.id}',
            tourId: tourData['id'],
            poiId: poi.id,
            orderIndex: item['order_index'],
            poi: poi);
      }).toList();

      final tour = Tour(
        id: tourData['id'],
        citySlug: tourData['city_slug'],
        titleRu: tourData['title_ru'],
        items: tourItemsWithAudio,
      );

      ref.read(tourModeServiceProvider.notifier).startTour(tour);
      if (mounted) context.push('/tour_mode');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _startTourWithManifest(String itineraryId) async {} // Deprecated
}
