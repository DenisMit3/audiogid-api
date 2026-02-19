// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StorageManager)
final storageManagerProvider = StorageManagerProvider._();

final class StorageManagerProvider
    extends $AsyncNotifierProvider<StorageManager, void> {
  StorageManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'storageManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$storageManagerHash();

  @$internal
  @override
  StorageManager create() => StorageManager();
}

String _$storageManagerHash() => r'd8228efaf7ac9d7a3935d34d9aa3d6ee5ab9a3f5';

abstract class _$StorageManager extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
