import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/data/services/analytics_service.dart';

class AnalyticsObserver extends RouteObserver<ModalRoute<void>> {
  final Ref ref;

  AnalyticsObserver(this.ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }

  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name;
    // GoRouter uses path as name usually if name is not set, or we can check matchedLocation from state if available.
    // But RouteObserver sees Route objects. PageRoute from GoRouter usually has settings.name set to path or name.

    if (screenName != null) {
      // Avoid logging internal redirects if possible
      ref
          .read(analyticsServiceProvider)
          .logEvent('screen_view', {'screen': screenName});
    }
  }
}
