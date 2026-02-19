// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_health_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(apiHealthService)
final apiHealthServiceProvider = ApiHealthServiceProvider._();

final class ApiHealthServiceProvider extends $FunctionalProvider<
    ApiHealthService,
    ApiHealthService,
    ApiHealthService> with $Provider<ApiHealthService> {
  ApiHealthServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'apiHealthServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$apiHealthServiceHash();

  @$internal
  @override
  $ProviderElement<ApiHealthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiHealthService create(Ref ref) {
    return apiHealthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiHealthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiHealthService>(value),
    );
  }
}

String _$apiHealthServiceHash() => r'9d2dfc140390d73458705dd761a3a5573cc90d5d';
