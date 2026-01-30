import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/domain/repositories/tour_repository.dart';
import 'package:mobile_flutter/domain/entities/tour.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/core/audio/audio_player_service.dart';
import 'package:mobile_flutter/data/services/tour_mode_service.dart';
import 'package:mobile_flutter/data/services/download_service.dart';
import 'package:mobile_flutter/data/services/notification_service.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:mobile_flutter/data/services/purchase_service.dart';

class TourDetailScreen extends ConsumerStatefulWidget {
  final String tourId;

  const TourDetailScreen({super.key, required this.tourId});

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  bool _isMultiSelectMode = false;
  bool _isBuying = false;
  final Set<String> _selectedPoiIds = {};

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider).valueOrNull;
    if (selectedCity == null) return const Scaffold();

    final tourStream = ref.watch(tourRepositoryProvider).watchTour(widget.tourId);

    return StreamBuilder<Tour?>(
      stream: tourStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final tour = snapshot.data;
        if (tour == null) {
          // Trigger sync if not found
          ref.read(tourRepositoryProvider).syncTourDetail(widget.tourId, selectedCity).ignore();
          return const Scaffold(body: Center(child: Text('Загрузка деталей тура...')));
        }

        final items = tour.items ?? [];

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, tour),
              _buildTourInfo(context, tour),
              _buildPoiList(context, items),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, tour),
        );
      },
    );
  }



  Widget _buildAppBar(BuildContext context, Tour tour) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          tour.titleRu,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 10, color: Colors.black)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              label: 'Карта маршрута: ${tour.titleRu}',
              image: true,
              excludeSemantics: true,
              child: _buildMapPreview(context, tour),
            ),
            // Gradient for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Напомнить о туре',
          onPressed: () => _showReminderDialog(context, tour),
        ),
        if (_isMultiSelectMode)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isMultiSelectMode = false;
                _selectedPoiIds.clear();
              });
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: 'Выбрать места',
            onPressed: () => setState(() => _isMultiSelectMode = true),
          ),
      ],
    );
  }

  Widget _buildMapPreview(BuildContext context, Tour tour) {
    final items = tour.items ?? [];
    if (items.isEmpty) return Container(color: Colors.grey[300]);

    final points = <LatLng>[];
    for (var item in items) {
      if (item.poi != null) {
        points.add(LatLng(item.poi!.lat, item.poi!.lon));
      }
    }

    if (points.isEmpty) return Container(color: Colors.grey[300]);

    // Calculate center
    double latSum = 0;
    double lonSum = 0;
    for (var p in points) {
      latSum += p.latitude;
      lonSum += p.longitude;
    }
    final center = LatLng(latSum / points.length, lonSum / points.length);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13, // TODO: Calculate fit bounds
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.audiogid.app',
        ),
        PolylineLayer(
          polylines: [
             Polyline(
               points: points,
               color: Theme.of(context).colorScheme.primary,
               strokeWidth: 4,
             ),
          ],
        ),
        MarkerLayer(
          markers: points.asMap().entries.map((entry) {
             return Marker(
               point: entry.value,
               width: 30,
               height: 30,
               child: Container(
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.primary,
                   shape: BoxShape.circle,
                   border: Border.all(color: Colors.white, width: 2),
                 ),
                 child: Center(
                    child: Text(
                      '${entry.key + 1}', 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                 ),
               ),
             );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _showReminderDialog(BuildContext context, Tour tour) async {
    final notificationService = ref.read(notificationServiceProvider);
    
    // Check permission first
    final hasPermission = await notificationService.hasNotificationPermission();
    if (!hasPermission) {
      final granted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Разрешить уведомления?'),
          content: const Text(
            'Для напоминаний о турах нам нужно разрешение на отправку уведомлений. '
            'Вы можете отключить их в любое время в настройках.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Не сейчас'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await notificationService.requestPermissionWithExplanation();
                if (ctx.mounted) Navigator.pop(ctx, result);
              },
              child: const Text('Разрешить'),
            ),
          ],
        ),
      );
      
      if (granted != true) return;
    }
    
    // Show reminder options
    if (!mounted) return;
    
    final result = await showModalBottomSheet<Duration?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Напомнить о туре',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Через 30 минут'),
              onTap: () => Navigator.pop(ctx, const Duration(minutes: 30)),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Через 1 час'),
              onTap: () => Navigator.pop(ctx, const Duration(hours: 1)),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Через 2 часа'),
              onTap: () => Navigator.pop(ctx, const Duration(hours: 2)),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Завтра в это время'),
              onTap: () => Navigator.pop(ctx, const Duration(days: 1)),
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Отменить напоминание'),
              onTap: () async {
                await notificationService.cancelTourReminder(tour.id);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Напоминание отменено')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    
    if (result != null && mounted) {
      await notificationService.scheduleRelativeTourReminder(
        tourId: tour.id,
        tourTitle: tour.titleRu,
        delay: result,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Напоминание установлено'),
            action: SnackBarAction(
              label: 'Отменить',
              onPressed: () => notificationService.cancelTourReminder(tour.id),
            ),
          ),
        );
      }
    }
  }

  Widget _buildTourInfo(BuildContext context, Tour tour) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _InfoChip(icon: Icons.timer_outlined, label: '${tour.durationMinutes ?? 0} мин'),
                const SizedBox(width: 8),
                _InfoChip(icon: Icons.route_outlined, label: '${tour.distanceKm?.toStringAsFixed(1) ?? '—'} км'),
                const SizedBox(width: 8),
                _InfoChip(icon: Icons.place_outlined, label: '${tour.items?.length ?? 0} локаций'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Описание',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              tour.descriptionRu ?? 'Этот маршрут проведет вас по самым интересным местам, раскрывая историю и культуру региона.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Список остановок',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoiList(BuildContext context, List<TourItemEntity> items) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Маршрут пуст'))),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final poi = item.poi;
          if (poi == null) return const ListTile(title: Text('Загрузка POI...'));

          final isSelected = _selectedPoiIds.contains(poi.id);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                onTap: () {
                  if (_isMultiSelectMode) {
                    setState(() {
                      if (isSelected) {
                        _selectedPoiIds.remove(poi.id);
                      } else {
                        _selectedPoiIds.add(poi.id);
                      }
                    });
                  } else {
                    context.push('/poi/${poi.id}');
                  }
                },
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text('${index + 1}'),
                ),
                title: Text(poi.titleRu, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(poi.descriptionRu ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline),
                        onPressed: () {
                           final validItems = items.where((i) => i.poi != null).toList();
                           final poiList = validItems.map((i) => i.poi!).toList();
                           // Find the actual index in the filtered list
                           final targetIndex = validItems.indexOf(item);
                           
                           ref.read(audioPlayerServiceProvider).loadPlaylist(
                             tourId: tour.id,
                             pois: poiList,
                             initialIndex: targetIndex,
                           );
                        },
                      ),
                    if (_isMultiSelectMode)
                      Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedPoiIds.add(poi.id);
                            } else {
                              _selectedPoiIds.remove(poi.id);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Tour tour) {
    if (_isMultiSelectMode) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Выбрано: ${_selectedPoiIds.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: (_selectedPoiIds.isEmpty || _isBuying)
                  ? null 
                  : () async {
                      setState(() => _isBuying = true);
                      try {
                        await ref.read(purchaseServiceProvider).buyBatch(
                          _selectedPoiIds.toList(), 
                          [], // No tours selected here
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Покупка успешно завершена')),
                          );
                          setState(() {
                             _isMultiSelectMode = false;
                             _selectedPoiIds.clear();
                          });
                        }
                      } catch (e) {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Ошибка покупки: $e')),
                           );
                         }
                      } finally {
                        if (mounted) setState(() => _isBuying = false);
                      }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isBuying 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Text('Купить выбранное'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Semantics(
          button: true,
          label: 'Начать тур',
          hint: 'Запустить режим навигации',
          child: ElevatedButton.icon(
            onPressed: () => _onStartTour(context, ref, tour),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.play_circle_filled),
            label: const Text('НАЧАТЬ ТУР', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Future<void> _onStartTour(BuildContext context, WidgetRef ref, Tour tour) async {
    int startIndex = 0;
    
    // Check saved progress
    final settings = await ref.read(settingsRepositoryProvider.future);
    final savedProgress = settings.getTourProgress();
    
    if (savedProgress != null && savedProgress['tourId'] == tour.id) {
       final savedIndex = savedProgress['stepIndex'] as int;
       final itemsCount = tour.items?.length ?? 0;
       
       if (savedIndex > 0 && savedIndex < itemsCount) {
           final resume = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                 title: const Text('Продолжить тур?'),
                 content: Text('Вы остановились на остановке ${savedIndex + 1}. Продолжить с этого места?'),
                 actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false), 
                      child: const Text('Начать сначала'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true), 
                      child: const Text('Продолжить'),
                    ),
                 ],
              ),
           );
           
           if (resume == true) {
              startIndex = savedIndex;
           } else {
              await settings.clearTourProgress();
           }
       }
    }

    final downloadedCities = await ref.read(downloadedCitiesProvider.future);
    bool proceed = true;

    if (!downloadedCities.contains(tour.citySlug)) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Тур не загружен'),
          content: const Text('Для работы аудиогида без интернета рекомендуется загрузить данные города. Продолжить онлайн?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
                context.push('/offline-manager');
              },
              child: const Text('Загрузить'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Продолжить онлайн'),
            ),
          ],
        ),
      );
      proceed = result ?? false;
    }

    if (proceed) {
      if (context.mounted) {
        // Log analytics
        ref.read(analyticsServiceProvider).logEvent('tour_started', {
          'tour_id': tour.id,
          'tour_name': tour.titleRu,
        });

        ref.read(tourModeServiceProvider.notifier).startTour(tour, startIndex: startIndex);
        context.push('/tour_mode');
      }
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
