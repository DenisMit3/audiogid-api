import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/presentation/widgets/audio/mini_player.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    int currentIndex = 0;
    if (location == '/nearby') currentIndex = 1;
    if (location == '/catalog') currentIndex = 2;
    if (location == '/favorites') currentIndex = 3;

    // Navigation items with semantic labels
    const navItems = [
      _NavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: 'Туры',
        semanticLabel: 'Туры - экскурсионные маршруты',
      ),
      _NavItem(
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
        label: 'Рядом',
        semanticLabel: 'Рядом - места поблизости на карте',
      ),
      _NavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view,
        label: 'Каталог',
        semanticLabel: 'Каталог - все достопримечательности',
      ),
      _NavItem(
        icon: Icons.bookmark_border_outlined,
        activeIcon: Icons.bookmark,
        label: 'Избранное',
        semanticLabel: 'Избранное - сохранённые места',
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: bottomPadding > 0 ? 0 : AppSpacing.xs,
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                // Provide haptic feedback
                HapticFeedback.lightImpact();
                
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/nearby');
                    break;
                  case 2:
                    context.go('/catalog');
                    break;
                  case 3:
                    context.go('/favorites');
                    break;
                }
              },
              animationDuration: AppDurations.normal,
              destinations: navItems.map((item) {
                return NavigationDestination(
                  icon: Semantics(
                    label: item.semanticLabel,
                    child: Icon(item.icon),
                  ),
                  selectedIcon: Icon(item.activeIcon),
                  label: item.label,
                  tooltip: item.semanticLabel,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String semanticLabel;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.semanticLabel,
  });
}
