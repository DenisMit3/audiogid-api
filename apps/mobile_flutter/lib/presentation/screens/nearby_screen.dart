import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/domain/entities/helper.dart';
import 'package:mobile_flutter/domain/entities/poi.dart' as entity;
import 'package:mobile_flutter/presentation/providers/nearby_providers.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:mobile_flutter/presentation/widgets/common/glass_widgets.dart';
import 'package:mobile_flutter/data/services/free_walking_service.dart';
import 'package:share_plus/share_plus.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen>
    with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  bool _permissionGranted = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
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

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final helpersAsync = ref.watch(nearbyHelpersProvider);
    final selectedType = ref.watch(selectedHelperTypeProvider);
    final userLocationAsync = ref.watch(userLocationStreamProvider);
    final cityAsync = ref.watch(selectedCityProvider);
    final citySlug = cityAsync.value;
    final freeWalkState = ref.watch(freeWalkingServiceProvider);

    final poisAsync = citySlug != null
        ? ref.watch(poiRepositoryProvider).watchPoisForCity(citySlug)
        : const Stream<List<entity.Poi>>.empty();

    // Handle permission denied state
    if (_permissionDenied) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          title: const Text('Рядом'),
          backgroundColor: AppColors.bgPrimary,
        ),
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
      backgroundColor: AppColors.bgPrimary,
      body: StreamBuilder<List<entity.Poi>>(
        stream: poisAsync,
        builder: (context, poisSnapshot) {
          final pois = poisSnapshot.data ?? [];

          return Stack(
            children: [
              // Map with dark style
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(54.7104, 20.4522),
                  initialZoom: 13,
                  backgroundColor: AppColors.bgPrimary,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  // Dark map tiles (CartoDB Dark Matter)
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.audiogid.app',
                    retinaMode: true,
                  ),

                  // Markers
                  helpersAsync.when(
                    data: (helpers) {
                      final filteredHelpers = selectedType == null
                          ? helpers
                          : helpers
                              .where((h) => h.type == selectedType)
                              .toList();

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

                      final allMarkers =
                          [...helperMarkers, ...poiMarkers].toList();

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
                                  gradient: AppGradients.primaryButton,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.accentPrimary.withOpacity(0.4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    markers.length.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                  color: AppColors.accentSecondary,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.accentSecondary.withOpacity(0.5),
                                      blurRadius: 12,
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
                        'CartoDB',
                        onTap: () => launchUrl(
                            Uri.parse('https://carto.com/attributions')),
                      ),
                      TextSourceAttribution(
                        'OpenStreetMap',
                        onTap: () => launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                ],
              ),

              // Gradient overlay at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.bgPrimary,
                        AppColors.bgPrimary.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Top controls
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.all(context.horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Рядом с вами',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // SOS Button
                          GlassFAB(
                            icon: Icons.sos,
                            onPressed: () => context.push('/sos'),
                            isPrimary: false,
                            tooltip: 'SOS - Экстренный вызов',
                            size: 44,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _GlassFilterChip(
                              label: 'Все',
                              icon: Icons.apps,
                              isSelected: selectedType == null,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(selectedHelperTypeProvider.notifier)
                                    .select(null);
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _GlassFilterChip(
                              label: 'Туалеты',
                              icon: Icons.wc,
                              isSelected: selectedType == HelperType.toilet,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(selectedHelperTypeProvider.notifier)
                                    .select(HelperType.toilet);
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _GlassFilterChip(
                              label: 'Кафе',
                              icon: Icons.local_cafe,
                              isSelected: selectedType == HelperType.cafe,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(selectedHelperTypeProvider.notifier)
                                    .select(HelperType.cafe);
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _GlassFilterChip(
                              label: 'Вода',
                              icon: Icons.water_drop,
                              isSelected:
                                  selectedType == HelperType.drinkingWater,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(selectedHelperTypeProvider.notifier)
                                    .select(HelperType.drinkingWater);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right side FAB buttons
              Positioned(
                right: context.horizontalPadding,
                bottom: MediaQuery.of(context).size.height * 0.35,
                child: Column(
                  children: [
                    // Share Location
                    GlassFAB(
                      icon: Icons.share,
                      onPressed: () {
                        final pos =
                            ref.read(userLocationStreamProvider).value;
                        if (pos != null) {
                          Share.share(
                              'Я здесь! https://maps.google.com/?q=${pos.latitude},${pos.longitude}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Местоположение не определено')),
                          );
                        }
                      },
                      isPrimary: false,
                      tooltip: 'Поделиться геолокацией',
                      size: 48,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // My location button
                    GlassFAB(
                      icon: Icons.my_location,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        final pos =
                            ref.read(userLocationStreamProvider).value;
                        if (pos != null) {
                          _mapController.move(
                              LatLng(pos.latitude, pos.longitude), 15);
                        } else {
                          _checkPermission();
                        }
                      },
                      isPrimary: true,
                      tooltip: 'Моё местоположение',
                      size: 48,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Free Walking Toggle
                    _FreeWalkButton(
                      isActive: freeWalkState.isActive,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        if (freeWalkState.isActive) {
                          ref
                              .read(freeWalkingServiceProvider.notifier)
                              .stop();
                        } else {
                          ref
                              .read(freeWalkingServiceProvider.notifier)
                              .start();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Свободная прогулка включена. Мы расскажем о местах рядом!')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Bottom sheet list
              DraggableScrollableSheet(
                initialChildSize: 0.15,
                minChildSize: 0.1,
                maxChildSize: 0.7,
                snap: true,
                snapSizes: const [0.15, 0.4, 0.7],
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
                      border: Border(
                        top: BorderSide(color: AppColors.glassBorder, width: 1),
                        left: BorderSide(color: AppColors.glassBorder, width: 1),
                        right: BorderSide(color: AppColors.glassBorder, width: 1),
                      ),
                    ),
                    child: helpersAsync.when(
                      data: (helpers) {
                        final filteredHelpers = selectedType == null
                            ? helpers
                            : helpers
                                .where((h) => h.type == selectedType)
                                .toList();

                        final allItems = [...pois, ...filteredHelpers];

                        if (allItems.isEmpty) {
                          return Column(
                            children: [
                              const GlassDragHandle(),
                              Expanded(
                                child: EmptyStateWidget.pois(),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom +
                                AppSpacing.lg,
                          ),
                          itemCount: allItems.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const GlassDragHandle();
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
                          const GlassDragHandle(),
                          const Expanded(child: SkeletonNearbyScreen()),
                        ],
                      ),
                      error: (e, s) => Column(
                        children: [
                          const GlassDragHandle(),
                          Expanded(
                            child: ErrorStateWidget.generic(
                              error: e.toString(),
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

  Widget _buildPoiMarker(entity.Poi poi) {
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
            color: AppColors.bgSecondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: poi.isFavorite ? AppColors.error : AppColors.accentPrimary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (poi.isFavorite ? AppColors.error : AppColors.accentPrimary)
                    .withOpacity(0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            Icons.place,
            size: 24,
            color: poi.isFavorite ? AppColors.error : AppColors.accentPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHelperMarker(Helper helper) {
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
            color: AppColors.bgSecondary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder, width: 2),
            boxShadow: AppShadows.card,
          ),
          child: Icon(
            _getIconForType(helper.type),
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPoiTile(entity.Poi poi) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: GlassCard(
        onTap: () {
          HapticFeedback.lightImpact();
          _mapController.move(LatLng(poi.lat, poi.lon), 16);
          context.push('/poi/${poi.id}');
        },
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.place,
                color: AppColors.accentPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.titleRu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    poi.category ?? 'Место',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                poi.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                color: poi.isFavorite
                    ? AppColors.accentPrimary
                    : AppColors.textTertiary,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(poiRepositoryProvider).toggleFavorite(poi.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperTile(Helper helper) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: GlassCard(
        onTap: () {
          HapticFeedback.lightImpact();
          _mapController.move(LatLng(helper.lat, helper.lon), 16);
        },
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                _getIconForType(helper.type),
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    helper.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (helper.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      helper.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.directions_outlined,
                color: AppColors.textTertiary,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // TODO: Open navigation
              },
            ),
          ],
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

class _GlassFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Фильтр: $label',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentPrimary.withOpacity(0.2)
                : AppColors.glassBg,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentPrimary.withOpacity(0.4)
                  : AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.accentPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.accentPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreeWalkButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;

  const _FreeWalkButton({
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isActive ? 'Выключить прогулку' : 'Включить свободную прогулку',
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive ? AppGradients.primaryButton : null,
            color: isActive ? null : AppColors.glassBg,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: isActive
                ? null
                : Border.all(color: AppColors.glassBorder, width: 1),
            boxShadow: AppShadows.fab,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? Icons.hearing : Icons.directions_walk,
                color: isActive ? Colors.white : AppColors.textPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'Слушаем...' : 'Прогулка',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
