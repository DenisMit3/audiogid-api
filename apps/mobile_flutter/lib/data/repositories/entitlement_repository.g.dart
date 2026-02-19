// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(entitlementRepository)
final entitlementRepositoryProvider = EntitlementRepositoryProvider._();

final class EntitlementRepositoryProvider extends $FunctionalProvider<
    EntitlementRepository,
    EntitlementRepository,
    EntitlementRepository> with $Provider<EntitlementRepository> {
  EntitlementRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'entitlementRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entitlementRepositoryHash();

  @$internal
  @override
  $ProviderElement<EntitlementRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EntitlementRepository create(Ref ref) {
    return entitlementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntitlementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntitlementRepository>(value),
    );
  }
}

String _$entitlementRepositoryHash() =>
    r'9cb3a3acbd5c2aecdf81a921b9fbf2d2233e5d8c';

@ProviderFor(entitlementGrants)
final entitlementGrantsProvider = EntitlementGrantsProvider._();

final class EntitlementGrantsProvider extends $FunctionalProvider<
        AsyncValue<List<domain.EntitlementGrant>>,
        List<domain.EntitlementGrant>,
        Stream<List<domain.EntitlementGrant>>>
    with
        $FutureModifier<List<domain.EntitlementGrant>>,
        $StreamProvider<List<domain.EntitlementGrant>> {
  EntitlementGrantsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'entitlementGrantsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$entitlementGrantsHash();

  @$internal
  @override
  $StreamProviderElement<List<domain.EntitlementGrant>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<domain.EntitlementGrant>> create(Ref ref) {
    return entitlementGrants(ref);
  }
}

String _$entitlementGrantsHash() => r'9c95c1936f13217aa218acdf4910d3ee74da9c5b';
