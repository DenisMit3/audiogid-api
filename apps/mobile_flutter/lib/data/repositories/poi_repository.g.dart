// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$poiRepositoryHash() => r'6eae529afdee95b161ba4ab274eebdf4dedc5d26';
