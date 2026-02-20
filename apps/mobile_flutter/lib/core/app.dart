import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/network/connectivity_service.dart';

// #region agent log
void _debugLog(String location, String message, Map<String, dynamic> data) {
  try {
    final logFile = File('/data/data/app.audiogid.mobile_flutter/files/debug.log');
    final entry = jsonEncode({
      'sessionId': '03cf79',
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    logFile.writeAsStringSync('$entry\n', mode: FileMode.append, flush: true);
  } catch (e) {
    debugPrint('DEBUG_LOG_ERROR: $e');
  }
}
// #endregion

class AudiogidApp extends ConsumerWidget {
  const AudiogidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // #region agent log
    _debugLog('app.dart:AudiogidApp:build', 'H8: AudiogidApp build called', {});
    // #endregion
    final router = ref.watch(routerProvider);
    // #region agent log
    _debugLog('app.dart:AudiogidApp:build:afterRouter', 'H8: router obtained', {'routerNull': router == null});
    // #endregion

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
        final mediaQuery = MediaQuery.of(context);
        final textScaleFactor = mediaQuery.textScaler.scale(1.0);
        final clampedTextScaler = TextScaler.linear(
          textScaleFactor.clamp(0.8, 1.6),
        );
        
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: clampedTextScaler,
          ),
          child: GestureDetector(
            onTap: () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: _AccessibilityWrapper(
              child: _ConnectivityWrapper(child: child),
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
    // #region agent log
    _debugLog('app.dart:ConnectivityWrapper:build', 'H9: ConnectivityWrapper build called', {});
    // #endregion
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
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
