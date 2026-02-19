// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider extends $FunctionalProvider<
        AsyncValue<SettingsRepository>,
        SettingsRepository,
        FutureOr<SettingsRepository>>
    with
        $FutureModifier<SettingsRepository>,
        $FutureProvider<SettingsRepository> {
  SettingsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SettingsRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsRepository> create(Ref ref) {
    return settingsRepository(ref);
  }
}

String _$settingsRepositoryHash() =>
    r'8af777a82a9747279bc00a463d38fd943916fde1';

@ProviderFor(SelectedCity)
final selectedCityProvider = SelectedCityProvider._();

final class SelectedCityProvider
    extends $AsyncNotifierProvider<SelectedCity, String?> {
  SelectedCityProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCityProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCityHash();

  @$internal
  @override
  SelectedCity create() => SelectedCity();
}

String _$selectedCityHash() => r'4e8bba00398813bd50819994cb1ac1afef531588';

abstract class _$SelectedCity extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<String?>, String?>,
        AsyncValue<String?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
