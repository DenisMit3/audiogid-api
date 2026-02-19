import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/itinerary_repository.dart';
import 'package:mobile_flutter/data/repositories/poi_repository.dart';
import 'package:mobile_flutter/data/services/tour_mode_service.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  const ItineraryScreen({super.key});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  @override
  Widget build(BuildContext context) {
    final itineraryIdsAsync = ref.watch(itineraryIdsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой маршрут'),
        actions: [
          // Share Button - only shown when POIs are loaded, but we need state access.
          // Simpler: Show it always, but handle empty inside.
          if (itineraryIdsAsync.value?.isNotEmpty == true)
             IconButton(
               icon: const Icon(Icons.share_outlined),
               tooltip: 'Поделиться маршрутом',
               onPressed: () async {
                  final ids = itineraryIdsAsync.value!;
                  final pois = await ref.read(poiRepositoryProvider).getPoisByIds(ids);
                  _shareItinerary(pois);
               },
             ),
          
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Очистить маршрут',
            onPressed: () {
               showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Очистить маршрут?'),
                  content: const Text('Все добавленные места будут удалены из списка.'),
                  actions: [
                    TextButton(onPressed: () => context.pop(), child: const Text('Отмена')),
                    TextButton(
                      onPressed: () {
                        ref.read(itineraryIdsProvider.notifier).clear();
                        context.pop();
                      },
                      child: const Text('Очистить'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: itineraryIdsAsync.when(
        data: (ids) {
          if (ids.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 64, color: colorScheme.outline),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Маршрут пуст',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Добавляйте интересные места на экране описания, чтобы создать свой уникальный маршрут.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: () => context.go('/catalog'),
                      child: const Text('Перейти в каталог'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Fetch POIs
          // Fetching logic: we need fetching based on IDs.
          return FutureBuilder<List<Poi>>(
             future: ref.read(poiRepositoryProvider).getPoisByIds(ids),
             builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.waiting) {
                 return const Center(child: CircularProgressIndicator());
               }
               
               if (snapshot.hasError) {
                  return ErrorStateWidget.generic(error: snapshot.error, onRetry: () => setState((){}));
               }
               
               final pois = snapshot.data ?? [];
               // Re-order based on IDs just in case, though repo handles it.
               
               return Column(
                 children: [
                   Container(
                     padding: const EdgeInsets.all(AppSpacing.md),
                     color: colorScheme.surfaceVariant.withOpacity(0.3),
                     child: Row(
                       children: [
                         const Icon(Icons.info_outline, size: 20),
                         const SizedBox(width: AppSpacing.sm),
                         Expanded(
                           child: Text(
                             'Удерживайте элементы, чтобы менять порядок',
                             style: Theme.of(context).textTheme.bodySmall,
                           ),
                         ),
                       ],
                     ),
                   ),
                   Expanded(
                     child: ReorderableListView.builder(
                       itemCount: pois.length,
                       onReorder: (oldIndex, newIndex) {
                          ref.read(itineraryIdsProvider.notifier).reorder(oldIndex, newIndex);
                          // We also update local list visually to avoid jump?
                          // The provider update triggers rebuild.
                       },
                       itemBuilder: (context, index) {
                         final poi = pois[index];
                         return ListTile(
                           key: ValueKey(poi.id),
                           leading: Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: colorScheme.surfaceVariant,
                                image: poi.media.isNotEmpty ? DecorationImage(
                                  image: NetworkImage(poi.media.first.url),
                                  fit: BoxFit.cover,
                                ) : null,
                              ),
                              child: poi.media.isEmpty ? const Icon(Icons.place) : null,
                           ),
                           title: Text(poi.titleRu, maxLines: 1, overflow: TextOverflow.ellipsis),
                           subtitle: Text(poi.category ?? 'Место'),
                           trailing: IconButton(
                             icon: const Icon(Icons.remove_circle_outline),
                             onPressed: () => ref.read(itineraryIdsProvider.notifier).remove(poi.id),
                           ),
                         );
                       },
                     ),
                   ),
                   SafeAreaWrapper(
                     bottom: true,
                     top: false,
                     child: Padding(
                       padding: const EdgeInsets.all(AppSpacing.md),
                       child: SizedBox(
                         width: double.infinity,
                         child: FilledButton.icon(
                           onPressed: () {
                              _startTour(pois);
                           },
                           icon: const Icon(Icons.play_arrow),
                           label: const Text('Начать прогулку'),
                           style: FilledButton.styleFrom(
                             padding: const EdgeInsets.all(AppSpacing.md),
                           ),
                         ),
                       ),
                     ),
                   ),
                 ],
               );
             },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => ErrorStateWidget.generic(error: e), 
      ),
    );
  }

  void _startTour(List<Poi> pois) {
    if (pois.isEmpty) return;
    
    // Create ephemeral tour
    final tour = Tour(
       id: 'custom_itinerary',
       citySlug: ref.read(selectedCityProvider).value ?? '',
       titleRu: 'Мой маршрут',
       items: pois.map((p) => TourItemEntity(id: p.id, tourId: 'custom_itinerary', poiId: p.id, orderIndex: 0, poi: p)).toList(), 
       // We don't have true TourItems but service handles logic.
    );
    
    ref.read(tourModeServiceProvider.notifier).startTour(tour);
    context.push('/tour_mode');
  }

  void _shareItinerary(List<Poi> pois) {
    if (pois.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('Мой маршрут с Audiogid:');
    buffer.writeln();
    
    for (int i = 0; i < pois.length; i++) {
      final p = pois[i];
      buffer.writeln('${i + 1}. ${p.titleRu}');
      buffer.writeln('https://audiogid.app/dl/poi/${p.id}');
      buffer.writeln();
    }
    
    buffer.writeln('Скачать приложение: https://audiogid.app');

    ref.read(analyticsServiceProvider).logEvent('share_itinerary', {
      'poi_count': pois.length,
      'city': ref.read(selectedCityProvider).value ?? 'unknown',
    });

    Share.share(buffer.toString(), subject: 'Мой маршрут');
  }
}
