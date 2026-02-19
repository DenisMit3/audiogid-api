// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_mode_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TourModeService)
final tourModeServiceProvider = TourModeServiceProvider._();

final class TourModeServiceProvider
    extends $NotifierProvider<TourModeService, TourModeState> {
  TourModeServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tourModeServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tourModeServiceHash();

  @$internal
  @override
  TourModeService create() => TourModeService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TourModeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TourModeState>(value),
    );
  }
}

String _$tourModeServiceHash() => r'b96bc478d2c643dba5182af822e39d9c16c11b58';

abstract class _$TourModeService extends $Notifier<TourModeState> {
  TourModeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TourModeState, TourModeState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TourModeState, TourModeState>,
        TourModeState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
