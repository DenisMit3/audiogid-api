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

    switch (flavor) {
      case AppFlavor.dev:
        return AppConfig(
          flavor: AppFlavor.dev,
          apiBaseUrl: apiBaseUrl.isNotEmpty ? apiBaseUrl : 'http://localhost:8000/v1',
        );
      case AppFlavor.staging:
        return AppConfig(
          flavor: AppFlavor.staging,
          apiBaseUrl: apiBaseUrl.isNotEmpty ? apiBaseUrl : 'https://audiogid-api-staging.vercel.app/v1',
        );
      case AppFlavor.prod:
        return AppConfig(
          flavor: AppFlavor.prod,
          // Cloud.ru VM - после открытия портов в Security Group
          apiBaseUrl: apiBaseUrl.isNotEmpty ? apiBaseUrl : 'http://82.202.159.64/v1',
        );
    }
  }
}

@riverpod
AppConfig appConfig(Ref ref) {
  // In a real app, you might get this from String.fromEnvironment('FLAVOR')
  const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final flavor = AppFlavor.values.firstWhere(
    (e) => e.name == flavorName,
    orElse: () => AppFlavor.dev,
  );
  return AppConfig.fromFlavor(flavor);
}
