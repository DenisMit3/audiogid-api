// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceId)
final deviceIdProvider = DeviceIdProvider._();

final class DeviceIdProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  DeviceIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deviceIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deviceIdHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return deviceId(ref);
  }
}

String _$deviceIdHash() => r'acbe0689da65f10b1a6bb02e2ec4cec816a75027';
