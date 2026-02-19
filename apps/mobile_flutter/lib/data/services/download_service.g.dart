// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DownloadService)
final downloadServiceProvider = DownloadServiceProvider._();

final class DownloadServiceProvider extends $NotifierProvider<DownloadService,
    Map<String, CityDownloadStatus>> {
  DownloadServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'downloadServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$downloadServiceHash();

  @$internal
  @override
  DownloadService create() => DownloadService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, CityDownloadStatus> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, CityDownloadStatus>>(value),
    );
  }
}

String _$downloadServiceHash() => r'303e11c6b1453e57a02c4195f3a0204ba00fb42a';

abstract class _$DownloadService
    extends $Notifier<Map<String, CityDownloadStatus>> {
  Map<String, CityDownloadStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, CityDownloadStatus>,
        Map<String, CityDownloadStatus>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, CityDownloadStatus>,
            Map<String, CityDownloadStatus>>,
        Map<String, CityDownloadStatus>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(downloadedCities)
final downloadedCitiesProvider = DownloadedCitiesProvider._();

final class DownloadedCitiesProvider extends $FunctionalProvider<
        AsyncValue<List<String>>, List<String>, FutureOr<List<String>>>
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  DownloadedCitiesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'downloadedCitiesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$downloadedCitiesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return downloadedCities(ref);
  }
}

String _$downloadedCitiesHash() => r'f066d45e04f6120cb731b0ac16c10618893c0dd3';
