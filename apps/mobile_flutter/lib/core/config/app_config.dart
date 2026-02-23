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
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    // Облачный сервер через nginx на порту 80
    const cloudUrl = 'http://82.202.159.64/v1';

    switch (flavor) {
      case AppFlavor.dev:
        return AppConfig(
          flavor: AppFlavor.dev,
          apiBaseUrl: apiBaseUrl.isNotEmpty ? apiBaseUrl : cloudUrl,
        );
      case AppFlavor.staging:
        return AppConfig(
          flavor: AppFlavor.staging,
          apiBaseUrl: apiBaseUrl.isNotEmpty ? apiBaseUrl : cloudUrl,
        );
      case AppFlavor.prod:
        return AppConfig(
          flavor: AppFlavor.prod,
          apiBaseUrl: apiBaseUrl.isNotEmpty ? apiBaseUrl : cloudUrl,
        );
    }
  }
}

@riverpod
AppConfig appConfig(Ref ref) {
  // In a real app, you might get this from String.fromEnvironment('FLAVOR')
  const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'staging');
  final flavor = AppFlavor.values.firstWhere(
    (e) => e.name == flavorName,
    orElse: () => AppFlavor.staging,
  );
  return AppConfig.fromFlavor(flavor);
}
