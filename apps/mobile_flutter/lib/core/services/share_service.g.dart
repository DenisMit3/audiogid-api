// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrustedContacts)
final trustedContactsProvider = TrustedContactsProvider._();

final class TrustedContactsProvider
    extends $AsyncNotifierProvider<TrustedContacts, List<TrustedContact>> {
  TrustedContactsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'trustedContactsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$trustedContactsHash();

  @$internal
  @override
  TrustedContacts create() => TrustedContacts();
}

String _$trustedContactsHash() => r'848a884e3f41ca424a608184cccf6f45d8079eaf';

abstract class _$TrustedContacts extends $AsyncNotifier<List<TrustedContact>> {
  FutureOr<List<TrustedContact>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<TrustedContact>>, List<TrustedContact>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<TrustedContact>>, List<TrustedContact>>,
        AsyncValue<List<TrustedContact>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(shareService)
final shareServiceProvider = ShareServiceProvider._();

final class ShareServiceProvider
    extends $FunctionalProvider<ShareService, ShareService, ShareService>
    with $Provider<ShareService> {
  ShareServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'shareServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$shareServiceHash();

  @$internal
  @override
  $ProviderElement<ShareService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareService create(Ref ref) {
    return shareService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareService>(value),
    );
  }
}

String _$shareServiceHash() => r'1b9d62107e28993d22134d114b79e3bb1e6d8998';
