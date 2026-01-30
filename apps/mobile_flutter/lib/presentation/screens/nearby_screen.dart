import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/domain/entities/helper.dart';
import 'package:mobile_flutter/domain/entities/poi.dart' as entity;
import 'package:mobile_flutter/presentation/providers/nearby_providers.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  final MapController _mapController = MapController();
  bool _permissionGranted = false;
  bool _permissionDenied = false;
  Style? _mapStyle;
  bool _isLoadingStyle = true;
  String? _mapError;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _loadMapStyle();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (mounted) {
      setState(() {
        _permissionGranted = status.isGranted;
        _permissionDenied = status.isDenied || status.isPermanentlyDenied;
      });
    }
  }

  Future<void> _loadMapStyle() async {
    final url = ref.read(mapStyleUrlProvider);
    try {
      final style = await StyleReader(
        uri: url,
        logger: const Logger.console(),
      ).read();
      if (mounted) {
        setState(() {
          _mapStyle = style;
          _isLoadingStyle = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load map style: $e');
      if (mounted) {
        setState(() {
          _mapError = e.toString();
          _isLoadingStyle = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final helpersAsync = ref.watch(nearbyHelpersProvider);
    final selectedType = ref.watch(selectedHelperTypeProvider);
    final userLocationAsync = ref.watch(userLocationStreamProvider);
    final cityAsync = ref.watch(selectedCityProvider);
    final citySlug = cityAsync.valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;

    final poisAsync = citySlug != null
        ? ref.watch(poiRepositoryProvider).watchPoisForCity(citySlug)
        : const Stream<List<entity.Poi>>.empty();

    // Handle permission denied state
    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: const Text('Рядом')),
        body: EmptyStateWidget.noLocation(
          onEnable: () async {
            HapticFeedback.lightImpact();
            await openAppSettings();
            await Future.delayed(const Duration(seconds: 1));
            _checkPermission();
          },
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<List<entity.Poi>>(
        stream: poisAsync,
        builder: (context, poisSnapshot) {
          final pois = poisSnapshot.data ?? [];

          return Stack(
            children: [
              // Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(54.7104, 20.4522),
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  // Map tiles
                  if (_mapStyle != null)
                    VectorTileLayer(
                      tileProviders: _mapStyle!.providers,
                      theme: _mapStyle!.theme,
                      sprites: _mapStyle!.sprites,
                      maximumZoom: 22,
                    )
                  else
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.audiogid.app',
                    ),

                  // Markers
                  helpersAsync.when(
                    data: (helpers) {
                      final filteredHelpers = selectedType == null
                          ? helpers
                          : helpers.where((h) => h.type == selectedType).toList();

                      final helperMarkers = filteredHelpers.map((h) => Marker(
                        point: LatLng(h.lat, h.lon),
                        width: 44,
                        height: 44,
                        child: _buildHelperMarker(h),
                      ));

                      final poiMarkers = pois.map((p) => Marker(
                        point: LatLng(p.lat, p.lon),
                        width: 48,
                        height: 48,
                        child: _buildPoiMarker(p),
                      ));

                      final allMarkers = [...helperMarkers, ...poiMarkers].toList();

                      return MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          maxClusterRadius: 45,
                          size: const Size(44, 44),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(50),
                          maxZoom: 15,
                          markers: allMarkers,
                          builder: (context, markers) {
                            return Semantics(
                              label: '${markers.length} объектов',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    markers.length.toString(),
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const MarkerLayer(markers: []),
                    error: (_, __) => const MarkerLayer(markers: []),
                  ),

                  // User location
                  if (_permissionGranted)
                    userLocationAsync.when(
                      data: (pos) => MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(pos.latitude, pos.longitude),
                            width: 24,
                            height: 24,
                            child: Semantics(
                              label: 'Ваше местоположение',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const MarkerLayer(markers: []),
                      error: (_, __) => const MarkerLayer(markers: []),
                    ),

                  // Attribution
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                      TextSourceAttribution(
                        'MapLibre',
                        onTap: () => launchUrl(Uri.parse('https://maplibre.org')),
                      ),
                    ],
                  ),
                ],
              ),

              // Top controls
              SafeAreaWrapper(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.all(context.horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // My location button
                      Semantics(
                        button: true,
                        label: 'Центрировать на моём местоположении',
                        child: FloatingActionButton.small(
                          heroTag: 'my_loc',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            final pos = ref.read(userLocationStreamProvider).value;
                            if (pos != null) {
                              _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
                            } else {
                              _checkPermission();
                            }
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Semantics(
                          label: 'Фильтры объектов',
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'Все',
                                icon: Icons.apps,
                                isSelected: selectedType == null,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ref.read(selectedHelperTypeProvider.notifier).select(null);
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _FilterChip(
                                label: 'Туалеты',
                                icon: Icons.wc,
                                isSelected: selectedType == HelperType.toilet,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ref.read(selectedHelperTypeProvider.notifier).select(HelperType.toilet);
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _FilterChip(
                                label: 'Кафе',
                                icon: Icons.local_cafe,
                                isSelected: selectedType == HelperType.cafe,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ref.read(selectedHelperTypeProvider.notifier).select(HelperType.cafe);
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _FilterChip(
                                label: 'Питьевая вода',
                                icon: Icons.water_drop,
                                isSelected: selectedType == HelperType.drinkingWater,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ref.read(selectedHelperTypeProvider.notifier).select(HelperType.drinkingWater);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom sheet list
              DraggableScrollableSheet(
                initialChildSize: 0.12,
                minChildSize: 0.1,
                maxChildSize: 0.6,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 16,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: helpersAsync.when(
                      data: (helpers) {
                        final filteredHelpers = selectedType == null
                            ? helpers
                            : helpers.where((h) => h.type == selectedType).toList();

                        final allItems = [...pois, ...filteredHelpers];

                        if (allItems.isEmpty) {
                          return Column(
                            children: [
                              _buildDragHandle(),
                              Expanded(
                                child: EmptyStateWidget.pois(),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
                          ),
                          itemCount: allItems.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildDragHandle();
                            }
                            final item = allItems[index - 1];
                            if (item is entity.Poi) {
                              return _buildPoiTile(item);
                            } else if (item is Helper) {
                              return _buildHelperTile(item);
                            }
                            return const SizedBox();
                          },
                        );
                      },
                      loading: () => Column(
                        children: [
                          _buildDragHandle(),
                          const Expanded(child: SkeletonNearbyScreen()),
                        ],
                      ),
                      error: (e, s) => Column(
                        children: [
                          _buildDragHandle(),
                          Expanded(
                            child: ErrorStateWidget.generic(
                              message: e.toString(),
                              onRetry: () {
                                ref.invalidate(nearbyHelpersProvider);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDragHandle() {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Потяните для развертывания списка',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoiMarker(entity.Poi poi) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Достопримечательность: ${poi.titleRu}',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _mapController.move(LatLng(poi.lat, poi.lon), 16);
          context.push('/poi/${poi.id}');
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: poi.isFavorite ? colorScheme.error : colorScheme.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.place,
            size: 24,
            color: poi.isFavorite ? colorScheme.error : colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHelperMarker(Helper helper) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '${_getTypeLabel(helper.type)}: ${helper.title}',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _mapController.move(LatLng(helper.lat, helper.lon), 16);
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.outline, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            _getIconForType(helper.type),
            size: 20,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPoiTile(entity.Poi poi) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: '${poi.titleRu}, ${poi.category ?? "Место"}',
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: AppSpacing.xs,
        ),
        child: ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            _mapController.move(LatLng(poi.lat, poi.lon), 16);
            context.push('/poi/${poi.id}');
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.place,
              color: colorScheme.primary,
            ),
          ),
          title: TitleText(
            poi.titleRu,
            maxLines: 1,
            style: textTheme.titleSmall,
          ),
          subtitle: LabelText(poi.category ?? 'Место'),
          trailing: AccessibleIconButton(
            icon: poi.isFavorite ? Icons.bookmark : Icons.bookmark_border,
            tooltip: poi.isFavorite ? 'Убрать из избранного' : 'Добавить в избранное',
            color: poi.isFavorite ? colorScheme.primary : null,
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(poiRepositoryProvider).toggleFavorite(poi.id);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHelperTile(Helper helper) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: '${_getTypeLabel(helper.type)}: ${helper.title}',
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: AppSpacing.xs,
        ),
        child: ListTile(
          onTap: () {
            HapticFeedback.lightImpact();
            _mapController.move(LatLng(helper.lat, helper.lon), 16);
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForType(helper.type),
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          title: TitleText(
            helper.title,
            maxLines: 1,
            style: textTheme.titleSmall,
          ),
          subtitle: LabelText(helper.address ?? ''),
          trailing: AccessibleIconButton(
            icon: Icons.directions_outlined,
            tooltip: 'Проложить маршрут',
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Open navigation
            },
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(HelperType type) {
    switch (type) {
      case HelperType.toilet:
        return Icons.wc;
      case HelperType.cafe:
        return Icons.local_cafe;
      case HelperType.drinkingWater:
        return Icons.water_drop;
      default:
        return Icons.place;
    }
  }

  String _getTypeLabel(HelperType type) {
    switch (type) {
      case HelperType.toilet:
        return 'Туалет';
      case HelperType.cafe:
        return 'Кафе';
      case HelperType.drinkingWater:
        return 'Питьевая вода';
      default:
        return 'Объект';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Фильтр: $label',
      child: Material(
        color: isSelected ? colorScheme.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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
