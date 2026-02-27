// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_walking_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FreeWalkingService)
final freeWalkingServiceProvider = FreeWalkingServiceProvider._();

final class FreeWalkingServiceProvider
    extends $NotifierProvider<FreeWalkingService, FreeWalkingState> {
  FreeWalkingServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'freeWalkingServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$freeWalkingServiceHash();

  @$internal
  @override
  FreeWalkingService create() => FreeWalkingService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FreeWalkingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FreeWalkingState>(value),
    );
  }
}

String _$freeWalkingServiceHash() =>
    r'69fe3969ebfdb93a8dcce1dc139110c4548ffd0d';

abstract class _$FreeWalkingService extends $Notifier<FreeWalkingState> {
  FreeWalkingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FreeWalkingState, FreeWalkingState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FreeWalkingState, FreeWalkingState>,
        FreeWalkingState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
