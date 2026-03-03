import 'dart:ui';
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.bgSecondary,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        extendBody: true,
        body: Column(
          children: [
            Expanded(child: child),
            const MiniPlayer(),
          ],
        ),
        bottomNavigationBar: _GlassNavigationBar(
          currentIndex: currentIndex,
          items: navItems,
          bottomPadding: bottomPadding,
          onTap: (index) {
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
        ),
      ),
    );
  }
}

class _GlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final double bottomPadding;
  final ValueChanged<int> onTap;

  const _GlassNavigationBar({
    required this.currentIndex,
    required this.items,
    required this.bottomPadding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: 8,
            bottom: bottomPadding > 0 ? 0 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              
              return _NavBarItem(
                item: item,
                isSelected: isSelected,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.semanticLabel,
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.accentPrimary.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected 
                      ? AppColors.accentPrimary 
                      : AppColors.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AppDurations.fast,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? AppColors.accentPrimary 
                      : AppColors.textTertiary,
                ),
                child: Text(item.label),
              ),
            ],
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
