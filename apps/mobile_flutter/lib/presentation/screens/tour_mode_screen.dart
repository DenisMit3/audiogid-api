
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/core/location/location_service.dart';
import 'package:mobile_flutter/data/services/tour_mode_service.dart';
import 'package:mobile_flutter/core/audio/providers.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/data/services/download_service.dart';

class TourModeScreen extends ConsumerStatefulWidget {
  const TourModeScreen({super.key});

  @override
  ConsumerState<TourModeScreen> createState() => _TourModeScreenState();
}

class _TourModeScreenState extends ConsumerState<TourModeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _shouldFollowUser = true;

  @override
  void initState() {
    super.initState();
    // Start listening to location updates
    ref.read(locationServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(tourModeServiceProvider);
    
    // Redirect if no tour is active
    if (!tourState.isActive || tourState.activeTour == null) {
      // Use addPostFrameCallback to avoid build issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.canPop()) {
           context.pop();
        } else {
           context.go('/');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeTour = tourState.activeTour!;
    final items = activeTour.items ?? [];
    
    // Filter only valid POIs for the map
    final validPois = items.map((i) => i.poi).whereType<Poi>().toList();
    final points = validPois.map((p) => LatLng(p.lat, p.lon)).toList();

    final userPosition = ref.watch(locationStreamProvider).valueOrNull;

    // Auto-center Logic
    if (_shouldFollowUser && userPosition != null) {
        _mapController.move(
          LatLng(userPosition.latitude, userPosition.longitude), 
          _mapController.camera.zoom
        );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: points.isNotEmpty ? points.first : const LatLng(59.93, 30.33),
              initialZoom: 15.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() => _shouldFollowUser = false);
                }
              },
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
                    color: Colors.blueAccent,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // User Marker
                  if (userPosition != null)
                    Marker(
                      point: LatLng(userPosition.latitude, userPosition.longitude),
                      width: 40,
                      height: 40,
                      child: const _UserMarker(),
                    ),
                  
                  // POI Markers
                  ...validPois.asMap().entries.map((entry) {
                    final index = entry.key;
                    final poi = entry.value;
                    final isCurrent = index == tourState.currentStepIndex;
                    final isPassed = index < tourState.currentStepIndex;
                    
                    return Marker(
                      point: LatLng(poi.lat, poi.lon),
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_on,
                        color: isCurrent 
                            ? Colors.red 
                            : (isPassed ? Colors.grey : Colors.blue),
                        size: isCurrent ? 50 : 35,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          
          // Re-center button
          if (!_shouldFollowUser)
            Positioned(
              right: 16,
              bottom: 250, // Above bottom card
              child: FloatingActionButton.small(
                onPressed: () => setState(() => _shouldFollowUser = true),
                child: const Icon(Icons.my_location),
              ),
            ),
            
          // Top Info Card
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Card(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.assistant_navigation),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tourState.currentPoi?.titleRu ?? 'Конец маршрута',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (tourState.distanceToNextPoi != null)
                             Text(
                               '${tourState.distanceToNextPoi!.toInt()} м${tourState.etaSeconds != null ? ' • ${_formatDuration(tourState.etaSeconds!)}' : ''}',
                               style: const TextStyle(color: Colors.grey),
                             ),
                        ],
                      ),
                    ),
                     
                    // AutoPlay Toggle
                    IconButton(
                      icon: Icon(
                        tourState.isAutoPlayEnabled ? Icons.volume_up : Icons.volume_off,
                        color: tourState.isAutoPlayEnabled ? Colors.green : Colors.grey,
                      ),
                      onPressed: () => ref.read(tourModeServiceProvider.notifier).toggleAutoPlay(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Off-Route Banner
          if (tourState.isOffRoute)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.orangeAccent.shade700,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Вы отклонились от маршрута",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _shouldFollowUser = true),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text("К МАРШРУТУ"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: _TourControls(
              state: tourState,
              totalSteps: validPois.length,
            ),
          ),
        ],
      ),
    );
  }
  String _formatDuration(int seconds) {
    if (seconds < 60) return '< 1 мин';
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes мин';
    final hours = (minutes / 60).floor();
    final mins = minutes % 60;
    return '$hours ч $mins мин';
  }
}

class _UserMarker extends StatelessWidget {

  const _UserMarker();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _TourControls extends ConsumerWidget {
  final TourModeState state;
  final int totalSteps;

  const _TourControls({required this.state, required this.totalSteps});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    
    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final isPlaying = playbackState?.playing ?? false;
        final processingState = playbackState?.processingState;
        final isBuffering = processingState == AudioProcessingState.buffering;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: totalSteps > 0 ? (state.currentStepIndex / totalSteps) : 0,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                'Остановка ${state.currentStepIndex + 1} из $totalSteps',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => ref.read(tourModeServiceProvider.notifier).prevStep(),
                    icon: const Icon(Icons.skip_previous),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                       if (isPlaying) {
                         audioHandler.pause();
                       } else {
                         audioHandler.play();
                       }
                    },
                    child: isBuffering 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: () => ref.read(tourModeServiceProvider.notifier).nextStep(),
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
              TextButton(
                 onPressed: () {
                   ref.read(tourModeServiceProvider.notifier).stopTour();
                   // Main shell is still under, popping context will probably go back to list or detail.
                   if (context.canPop()) context.pop();
                 },
                 child: const Text('Завершить тур', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
    );
  }
}
