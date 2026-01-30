import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

enum AppFlavor {
  dev,
  staging,
  prod,
}

class AppConfig {
  final AppFlavor flavor;
  final String apiBaseUrl;

  AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
  });

  factory AppConfig.fromFlavor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.dev:
        return AppConfig(
          flavor: AppFlavor.dev,
          apiBaseUrl: 'https://dev.api.audiogid.app/v1',
        );
      case AppFlavor.staging:
        return AppConfig(
          flavor: AppFlavor.staging,
          apiBaseUrl: 'https://staging.api.audiogid.app/v1',
        );
      case AppFlavor.prod:
        return AppConfig(
          flavor: AppFlavor.prod,
          apiBaseUrl: 'https://api.audiogid.app/v1',
        );
    }
  }
}

@riverpod
AppConfig appConfig(AppConfigRef ref) {
  // In a real app, you might get this from String.fromEnvironment('FLAVOR')
  const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final flavor = AppFlavor.values.firstWhere(
    (e) => e.name == flavorName,
    orElse: () => AppFlavor.dev,
  );
  return AppConfig.fromFlavor(flavor);
}
