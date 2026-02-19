// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cityRepository)
final cityRepositoryProvider = CityRepositoryProvider._();

final class CityRepositoryProvider
    extends $FunctionalProvider<CityRepository, CityRepository, CityRepository>
    with $Provider<CityRepository> {
  CityRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cityRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cityRepositoryHash();

  @$internal
  @override
  $ProviderElement<CityRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CityRepository create(Ref ref) {
    return cityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CityRepository>(value),
    );
  }
}

String _$cityRepositoryHash() => r'fa620fd62dda8266c4dc368fd9de67e9ed6ca4a6';
