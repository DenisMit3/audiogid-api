// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inAppPurchase)
final inAppPurchaseProvider = InAppPurchaseProvider._();

final class InAppPurchaseProvider
    extends $FunctionalProvider<InAppPurchase, InAppPurchase, InAppPurchase>
    with $Provider<InAppPurchase> {
  InAppPurchaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inAppPurchaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inAppPurchaseHash();

  @$internal
  @override
  $ProviderElement<InAppPurchase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InAppPurchase create(Ref ref) {
    return inAppPurchase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InAppPurchase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InAppPurchase>(value),
    );
  }
}

String _$inAppPurchaseHash() => r'd2388a0c220ac74d20580556be0896d1eac71cdc';

@ProviderFor(PurchaseService)
final purchaseServiceProvider = PurchaseServiceProvider._();

final class PurchaseServiceProvider
    extends $NotifierProvider<PurchaseService, PurchaseState> {
  PurchaseServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'purchaseServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$purchaseServiceHash();

  @$internal
  @override
  PurchaseService create() => PurchaseService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseState>(value),
    );
  }
}

String _$purchaseServiceHash() => r'6ef85a409485224f9b9c9189de2aad0d993ea953';

abstract class _$PurchaseService extends $Notifier<PurchaseState> {
  PurchaseState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PurchaseState, PurchaseState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PurchaseState, PurchaseState>,
        PurchaseState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
