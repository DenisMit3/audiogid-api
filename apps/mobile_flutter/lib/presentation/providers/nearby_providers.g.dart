// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(helperRepository)
final helperRepositoryProvider = HelperRepositoryProvider._();

final class HelperRepositoryProvider extends $FunctionalProvider<
    HelperRepository,
    HelperRepository,
    HelperRepository> with $Provider<HelperRepository> {
  HelperRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'helperRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$helperRepositoryHash();

  @$internal
  @override
  $ProviderElement<HelperRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HelperRepository create(Ref ref) {
    return helperRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HelperRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HelperRepository>(value),
    );
  }
}

String _$helperRepositoryHash() => r'18fdfc3fe238736b0ef366473241697046042bf4';

@ProviderFor(poiRepository)
final poiRepositoryProvider = PoiRepositoryProvider._();

final class PoiRepositoryProvider
    extends $FunctionalProvider<PoiRepository, PoiRepository, PoiRepository>
    with $Provider<PoiRepository> {
  PoiRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'poiRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$poiRepositoryHash();

  @$internal
  @override
  $ProviderElement<PoiRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PoiRepository create(Ref ref) {
    return poiRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PoiRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PoiRepository>(value),
    );
  }
}

String _$poiRepositoryHash() => r'1d7d5147c3948ccd749c2679e9dd82d169dc9fb2';

@ProviderFor(nearbyHelpers)
final nearbyHelpersProvider = NearbyHelpersProvider._();

final class NearbyHelpersProvider extends $FunctionalProvider<
        AsyncValue<List<Helper>>, List<Helper>, FutureOr<List<Helper>>>
    with $FutureModifier<List<Helper>>, $FutureProvider<List<Helper>> {
  NearbyHelpersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'nearbyHelpersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$nearbyHelpersHash();

  @$internal
  @override
  $FutureProviderElement<List<Helper>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Helper>> create(Ref ref) {
    return nearbyHelpers(ref);
  }
}

String _$nearbyHelpersHash() => r'584b120d47327a06cb180f04e2f6d580b8086ca1';

@ProviderFor(mapStyleUrl)
final mapStyleUrlProvider = MapStyleUrlProvider._();

final class MapStyleUrlProvider
    extends $FunctionalProvider<String, String, String> with $Provider<String> {
  MapStyleUrlProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mapStyleUrlProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mapStyleUrlHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return mapStyleUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$mapStyleUrlHash() => r'008d948f7a9a529e83192654119aa9ff2ff8f002';

@ProviderFor(userLocationStream)
final userLocationStreamProvider = UserLocationStreamProvider._();

final class UserLocationStreamProvider extends $FunctionalProvider<
        AsyncValue<Position>, Position, Stream<Position>>
    with $FutureModifier<Position>, $StreamProvider<Position> {
  UserLocationStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userLocationStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userLocationStreamHash();

  @$internal
  @override
  $StreamProviderElement<Position> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Position> create(Ref ref) {
    return userLocationStream(ref);
  }
}

String _$userLocationStreamHash() =>
    r'eb810614df6643266d235c0a9b3b40b15f87a2e6';

@ProviderFor(SelectedHelperType)
final selectedHelperTypeProvider = SelectedHelperTypeProvider._();

final class SelectedHelperTypeProvider
    extends $NotifierProvider<SelectedHelperType, HelperType?> {
  SelectedHelperTypeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedHelperTypeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedHelperTypeHash();

  @$internal
  @override
  SelectedHelperType create() => SelectedHelperType();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HelperType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HelperType?>(value),
    );
  }
}

String _$selectedHelperTypeHash() =>
    r'b6d69517310cce67f43fa0ece0d97bb363ff3dae';

abstract class _$SelectedHelperType extends $Notifier<HelperType?> {
  HelperType? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HelperType?, HelperType?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HelperType?, HelperType?>, HelperType?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
