import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/data/services/sync_service.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';

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

class CitySelectScreen extends ConsumerStatefulWidget {
  const CitySelectScreen({super.key});

  @override
  ConsumerState<CitySelectScreen> createState() => _CitySelectScreenState();
}

class _CitySelectScreenState extends ConsumerState<CitySelectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  String? _selectedSlug;

  @override
  void initState() {
    super.initState();
    // #region agent log
    _debugLog('city_select_screen.dart:initState', 'H7: CitySelectScreen initState called', {});
    // #endregion
    
    _animController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: AppCurves.emphasized,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: AppCurves.emphasized,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // #region agent log
    _debugLog('city_select_screen.dart:build', 'H11: CitySelectScreen build called', {});
    // #endregion
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.6),
              colorScheme.surface,
              colorScheme.secondaryContainer.withOpacity(0.3),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeAreaWrapper(
          child: ResponsivePadding(
            child: ResponsiveContainer(
              maxWidth: 500,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 2),
                      
                      // App icon with animation
                      AnimatedContent(
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.headphones_outlined,
                            size: context.responsive(
                              smallPhone: 60.0,
                              phone: 80.0,
                              tablet: 100.0,
                            ),
                            color: colorScheme.primary,
                            semanticLabel: 'Иконка аудиогида',
                          ),
                        ),
                      ),
                      
                      SizedBox(height: context.responsive(
                        smallPhone: AppSpacing.md,
                        phone: AppSpacing.lg,
                        tablet: AppSpacing.xl,
                      )),
                      
                      // Welcome text
                      AnimatedContent(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            AccessibleHeader(
                              text: 'Добро пожаловать в\nАудиогид',
                              level: 1,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Выберите регион для начала путешествия',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(flex: 2),
                      
                      // City selection buttons
                      AnimatedContent(
                        delay: const Duration(milliseconds: 300),
                        child: _CityButton(
                          title: 'Калининград',
                          subtitle: 'Городской гид',
                          slug: 'kaliningrad_city',
                          icon: Icons.location_city_outlined,
                          isLoading: _isLoading && _selectedSlug == 'kaliningrad_city',
                          onTap: () => _selectCity('kaliningrad_city'),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      AnimatedContent(
                        delay: const Duration(milliseconds: 400),
                        child: _CityButton(
                          title: 'Калининградская область',
                          subtitle: 'Пригородные маршруты',
                          slug: 'kaliningrad_oblast',
                          icon: Icons.landscape_outlined,
                          isLoading: _isLoading && _selectedSlug == 'kaliningrad_oblast',
                          onTap: () => _selectCity('kaliningrad_oblast'),
                        ),
                      ),
                      
                      const Spacer(flex: 3),
                      
                      // Terms text
                      AnimatedContent(
                        delay: const Duration(milliseconds: 500),
                        child: Text(
                          'Продолжая, вы соглашаетесь с условиями использования и политикой конфиденциальности',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectCity(String slug) async {
    // #region agent log
    _debugLog('city_select_screen.dart:_selectCity:start', 'H16: _selectCity started', {'slug': slug, 'mounted': mounted});
    // #endregion
    
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    
    setState(() {
      _isLoading = true;
      _selectedSlug = slug;
    });

    try {
      // #region agent log
      _debugLog('city_select_screen.dart:_selectCity:before_set', 'H16: Before selectedCityProvider.set', {'mounted': mounted});
      // #endregion
      
      if (!mounted) {
        // #region agent log
        _debugLog('city_select_screen.dart:_selectCity:not_mounted_1', 'H16: Not mounted before set', {});
        // #endregion
        return;
      }
      
      final notifier = ref.read(selectedCityProvider.notifier);
      // #region agent log
      _debugLog('city_select_screen.dart:_selectCity:got_notifier', 'H16: Got notifier', {'notifier': notifier.toString()});
      // #endregion
      
      await notifier.set(slug);
      
      // #region agent log
      _debugLog('city_select_screen.dart:_selectCity:after_set', 'H16: After set', {'mounted': mounted});
      // #endregion
      
      if (!mounted) {
        // #region agent log
        _debugLog('city_select_screen.dart:_selectCity:not_mounted_2', 'H16: Not mounted after set', {});
        // #endregion
        return;
      }
      
      // #region agent log
      _debugLog('city_select_screen.dart:_selectCity:before_sync', 'H16: Before syncAll', {});
      // #endregion
      
      // Trigger initial sync
      ref.read(syncServiceProvider).syncAll(slug).ignore();
      
      // #region agent log
      _debugLog('city_select_screen.dart:_selectCity:before_go', 'H16: Before context.go', {'mounted': mounted});
      // #endregion
      
      if (mounted) {
        context.go('/');
      }
      
      // #region agent log
      _debugLog('city_select_screen.dart:_selectCity:done', 'H16: _selectCity completed', {});
      // #endregion
    } catch (e, st) {
      // #region agent log
      _debugLog('city_select_screen.dart:_selectCity:error', 'H16: Error in _selectCity', {'error': e.toString(), 'stackTrace': st.toString().substring(0, 500)});
      // #endregion
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedSlug = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _CityButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final String slug;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _CityButton({
    required this.title,
    required this.subtitle,
    required this.slug,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_CityButton> createState() => _CityButtonState();
}

class _CityButtonState extends State<_CityButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.instant,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: '${widget.title}, ${widget.subtitle}',
      hint: 'Нажмите чтобы выбрать этот регион',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: Container(
            padding: EdgeInsets.all(context.cardPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(
                          widget.icon,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                ),
                
                const SizedBox(width: AppSpacing.md),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(
                        widget.title,
                        maxLines: 1,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      LabelText(widget.subtitle),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
