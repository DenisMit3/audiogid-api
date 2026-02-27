import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/network/connectivity_service.dart';
import 'package:mobile_flutter/core/services/app_update_service.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/presentation/widgets/soft_update_banner.dart';

class AudiogidApp extends ConsumerWidget {
  const AudiogidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Аудиогид',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router configuration
      routerConfig: router,

      // Localization - Russian only for MVP
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Builder for global wrappers
      builder: (context, child) {
        // Get the text scale factor and clamp it for accessibility
        final mediaQuery = MediaQuery.of(context);
        final textScaleFactor = mediaQuery.textScaler.scale(1.0);

        // Allow font scaling up to 1.6 (160%) but prevent layout breaking
        // at extreme scales
        final clampedTextScaler = TextScaler.linear(
          textScaleFactor.clamp(0.8, 1.6),
        );

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: clampedTextScaler,
          ),
          child: GestureDetector(
            // Dismiss keyboard on tap outside
            onTap: () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: _UpdateBannerWrapper(
              child: _AccessibilityWrapper(
                child: _ConnectivityWrapper(child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConnectivityWrapper extends ConsumerWidget {
  final Widget? child;
  const _ConnectivityWrapper({this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need to import the provider first, but to keep clean file edits we assume imports are handled or we add them.
    // Actually imports are needed. I will check imports in next step if this fails or add them now if I can.
    // Since I can't easily add global imports in replace_file_content, I'll rely on a second pass or the user context.
    // Wait, I should add imports at the top of file first.
    // Or I can add them in this block if I was replacing whole file.
    // I will try to use full path if possible or just assume imports.
    // BUT `ConnectivityService` is new.

    // Let's implement the UI logic first.
    final status = ref.watch(connectivityServiceProvider);

    return Stack(
      children: [
        if (child != null) child!,
        if (status == ConnectionStatus.offline)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.redAccent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Нет подключения к интернету',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Wrapper that provides accessibility features
class _AccessibilityWrapper extends StatelessWidget {
  final Widget child;

  const _AccessibilityWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // Indicate this is an app
      container: true,
      child: child,
    );
  }
}

/// Wrapper для показа мягкого напоминания об обновлении
class _UpdateBannerWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const _UpdateBannerWrapper({required this.child});

  @override
  ConsumerState<_UpdateBannerWrapper> createState() =>
      _UpdateBannerWrapperState();
}

class _UpdateBannerWrapperState extends ConsumerState<_UpdateBannerWrapper> {
  bool _showBanner = false;
  AppUpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    _checkForSoftUpdate();
  }

  Future<void> _checkForSoftUpdate() async {
    try {
      final settings = await ref.read(settingsRepositoryProvider.future);
      if (!settings.shouldShowUpdatePrompt()) return;

      final updateInfo =
          await ref.read(appUpdateServiceProvider).checkForUpdate();

      if (updateInfo.updateAvailable && !updateInfo.forceUpdate) {
        setState(() {
          _showBanner = true;
          _updateInfo = updateInfo;
        });
      }
    } catch (e) {
      debugPrint('Soft update check failed: $e');
    }
  }

  Future<void> _dismissBanner() async {
    final settings = await ref.read(settingsRepositoryProvider.future);
    await settings.setLastUpdatePromptDate(DateTime.now());
    setState(() => _showBanner = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showBanner && _updateInfo != null)
          SoftUpdateBanner(
            message: _updateInfo!.messageRu ?? 'Доступны улучшения',
            storeUrl: _updateInfo!.storeUrl,
            newVersion: _updateInfo!.currentVersion,
            onDismiss: _dismissBanner,
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
