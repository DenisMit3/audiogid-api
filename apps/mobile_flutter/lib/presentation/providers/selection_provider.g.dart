// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectionNotifier)
final selectionProvider = SelectionNotifierProvider._();

final class SelectionNotifierProvider
    extends $NotifierProvider<SelectionNotifier, Set<String>> {
  SelectionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectionNotifierHash();

  @$internal
  @override
  SelectionNotifier create() => SelectionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$selectionNotifierHash() => r'b1e45b39643f148bfdc8288fd77b46e134d89ef0';

abstract class _$SelectionNotifier extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<String>, Set<String>>, Set<String>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
