// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConnectivityService)
final connectivityServiceProvider = ConnectivityServiceProvider._();

final class ConnectivityServiceProvider
    extends $NotifierProvider<ConnectivityService, ConnectionStatus> {
  ConnectivityServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceHash();

  @$internal
  @override
  ConnectivityService create() => ConnectivityService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionStatus>(value),
    );
  }
}

String _$connectivityServiceHash() =>
    r'70c85266aefc0d69084fe0bc6bfb031f6e31fc06';

abstract class _$ConnectivityService extends $Notifier<ConnectionStatus> {
  ConnectionStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConnectionStatus, ConnectionStatus>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ConnectionStatus, ConnectionStatus>,
        ConnectionStatus,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
