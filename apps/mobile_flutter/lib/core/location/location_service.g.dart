// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(locationService)
final locationServiceProvider = LocationServiceProvider._();

final class LocationServiceProvider extends $FunctionalProvider<LocationService,
    LocationService, LocationService> with $Provider<LocationService> {
  LocationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationServiceHash();

  @$internal
  @override
  $ProviderElement<LocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationService create(Ref ref) {
    return locationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationService>(value),
    );
  }
}

String _$locationServiceHash() => r'6efe460a90c6d1e1228f1e6981fbf2098942069d';

@ProviderFor(locationStream)
final locationStreamProvider = LocationStreamProvider._();

final class LocationStreamProvider extends $FunctionalProvider<
        AsyncValue<Position>, Position, Stream<Position>>
    with $FutureModifier<Position>, $StreamProvider<Position> {
  LocationStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'locationStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationStreamHash();

  @$internal
  @override
  $StreamProviderElement<Position> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Position> create(Ref ref) {
    return locationStream(ref);
  }
}

String _$locationStreamHash() => r'f2e5c39bd045bbf75901034b953eee24a6d1697a';
