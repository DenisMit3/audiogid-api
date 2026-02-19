// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(itineraryRepository)
final itineraryRepositoryProvider = ItineraryRepositoryProvider._();

final class ItineraryRepositoryProvider extends $FunctionalProvider<
        AsyncValue<ItineraryRepository>,
        ItineraryRepository,
        FutureOr<ItineraryRepository>>
    with
        $FutureModifier<ItineraryRepository>,
        $FutureProvider<ItineraryRepository> {
  ItineraryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ItineraryRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ItineraryRepository> create(Ref ref) {
    return itineraryRepository(ref);
  }
}

String _$itineraryRepositoryHash() =>
    r'4e2e4923f5f2fd6ae29bee11ab23ea504e67bfb1';

@ProviderFor(ItineraryIds)
final itineraryIdsProvider = ItineraryIdsProvider._();

final class ItineraryIdsProvider
    extends $AsyncNotifierProvider<ItineraryIds, List<String>> {
  ItineraryIdsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itineraryIdsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itineraryIdsHash();

  @$internal
  @override
  ItineraryIds create() => ItineraryIds();
}

String _$itineraryIdsHash() => r'ac1fc7c4bc40114dc79c47b6541c2ad59b52b850';

abstract class _$ItineraryIds extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<String>>, List<String>>,
        AsyncValue<List<String>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
