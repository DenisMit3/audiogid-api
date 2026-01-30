import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/router/app_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

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
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: _AccessibilityWrapper(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
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
