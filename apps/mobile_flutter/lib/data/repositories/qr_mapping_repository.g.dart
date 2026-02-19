// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_mapping_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(qrMappingRepository)
final qrMappingRepositoryProvider = QrMappingRepositoryProvider._();

final class QrMappingRepositoryProvider extends $FunctionalProvider<
    QrMappingRepository,
    QrMappingRepository,
    QrMappingRepository> with $Provider<QrMappingRepository> {
  QrMappingRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'qrMappingRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$qrMappingRepositoryHash();

  @$internal
  @override
  $ProviderElement<QrMappingRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QrMappingRepository create(Ref ref) {
    return qrMappingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QrMappingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QrMappingRepository>(value),
    );
  }
}

String _$qrMappingRepositoryHash() =>
    r'780dd97f8461a123d0618d08bf0af171b5ca9614';
