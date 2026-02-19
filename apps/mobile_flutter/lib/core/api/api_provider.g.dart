// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dioProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'2ac0ef71f030f296c1f3b1b90fa83809f8ecc0a0';

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  ApiClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'apiClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'4ef6edf3249cff4a568a8eaf1f25750f97ff526f';

@ProviderFor(publicApi)
final publicApiProvider = PublicApiProvider._();

final class PublicApiProvider
    extends $FunctionalProvider<PublicApi, PublicApi, PublicApi>
    with $Provider<PublicApi> {
  PublicApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'publicApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$publicApiHash();

  @$internal
  @override
  $ProviderElement<PublicApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PublicApi create(Ref ref) {
    return publicApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PublicApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PublicApi>(value),
    );
  }
}

String _$publicApiHash() => r'b3c7e42f63a637a5e6bdd3cb992f06dc20e5ab38';

@ProviderFor(billingApi)
final billingApiProvider = BillingApiProvider._();

final class BillingApiProvider
    extends $FunctionalProvider<BillingApi, BillingApi, BillingApi>
    with $Provider<BillingApi> {
  BillingApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'billingApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$billingApiHash();

  @$internal
  @override
  $ProviderElement<BillingApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BillingApi create(Ref ref) {
    return billingApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillingApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillingApi>(value),
    );
  }
}

String _$billingApiHash() => r'0f843a23629121f03c85bd7e045d64f2d1623def';

@ProviderFor(accountApi)
final accountApiProvider = AccountApiProvider._();

final class AccountApiProvider
    extends $FunctionalProvider<AccountApi, AccountApi, AccountApi>
    with $Provider<AccountApi> {
  AccountApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountApiHash();

  @$internal
  @override
  $ProviderElement<AccountApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountApi create(Ref ref) {
    return accountApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountApi>(value),
    );
  }
}

String _$accountApiHash() => r'd3e1af633017cc2aa34a0c12e2d5257d29ec8597';

@ProviderFor(authApi)
final authApiProvider = AuthApiProvider._();

final class AuthApiProvider
    extends $FunctionalProvider<AuthApi, AuthApi, AuthApi>
    with $Provider<AuthApi> {
  AuthApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authApiHash();

  @$internal
  @override
  $ProviderElement<AuthApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthApi create(Ref ref) {
    return authApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthApi>(value),
    );
  }
}

String _$authApiHash() => r'6ef2829b0c4ce21713590400bbe699e843fe460f';

@ProviderFor(offlineApi)
final offlineApiProvider = OfflineApiProvider._();

final class OfflineApiProvider
    extends $FunctionalProvider<OfflineApi, OfflineApi, OfflineApi>
    with $Provider<OfflineApi> {
  OfflineApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'offlineApiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$offlineApiHash();

  @$internal
  @override
  $ProviderElement<OfflineApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OfflineApi create(Ref ref) {
    return offlineApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OfflineApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OfflineApi>(value),
    );
  }
}

String _$offlineApiHash() => r'0b05f9c888e7b66ec7dce0c1349926115f23b217';
