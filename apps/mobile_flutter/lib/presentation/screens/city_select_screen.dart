import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/data/repositories/city_repository.dart';
import 'package:mobile_flutter/data/services/sync_service.dart';
import 'package:mobile_flutter/domain/entities/city.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final citiesStream = ref.watch(cityRepositoryProvider).watchCities();

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
                      const SizedBox(height: AppSpacing.xl),
                      
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
                            Icons.location_city_outlined,
                            size: context.responsive(
                              smallPhone: 48.0,
                              phone: 64.0,
                              tablet: 80.0,
                            ),
                            color: colorScheme.primary,
                            semanticLabel: 'Выбор города',
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
                              text: 'Выберите город',
                              level: 1,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Для начала путешествия',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // City list from API
                      Expanded(
                        child: StreamBuilder<List<City>>(
                          stream: citiesStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting && 
                                !snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: colorScheme.error,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Ошибка загрузки городов',
                                      style: textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    TextButton(
                                      onPressed: () => setState(() {}),
                                      child: const Text('Повторить'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final cities = snapshot.data ?? [];
                            
                            if (cities.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_off_outlined,
                                      size: 48,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Нет доступных городов',
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    TextButton(
                                      onPressed: () => setState(() {}),
                                      child: const Text('Обновить'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Фильтруем только активные города
                            final activeCities = cities.where((c) => c.isActive).toList();

                            return ListView.separated(
                              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                              itemCount: activeCities.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final city = activeCities[index];
                                return AnimatedContent(
                                  delay: Duration(milliseconds: 300 + (index * 100)),
                                  child: _CityButton(
                                    title: city.nameRu,
                                    subtitle: _getCitySubtitle(city.slug),
                                    slug: city.slug,
                                    icon: _getCityIcon(city.slug),
                                    isLoading: _isLoading && _selectedSlug == city.slug,
                                    onTap: () => _selectCity(city.slug),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      
                      // Terms text
                      AnimatedContent(
                        delay: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Text(
                            'Продолжая, вы соглашаетесь с условиями использования',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
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

  String _getCitySubtitle(String slug) {
    switch (slug) {
      case 'kaliningrad_city':
        return 'Городской гид';
      case 'kaliningrad_oblast':
        return 'Пригородные маршруты';
      case 'nizhny_novgorod':
        return 'Волжская жемчужина';
      default:
        return 'Аудиогид по городу';
    }
  }

  IconData _getCityIcon(String slug) {
    switch (slug) {
      case 'kaliningrad_city':
        return Icons.location_city_outlined;
      case 'kaliningrad_oblast':
        return Icons.landscape_outlined;
      case 'nizhny_novgorod':
        return Icons.water_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  Future<void> _selectCity(String slug) async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    
    setState(() {
      _isLoading = true;
      _selectedSlug = slug;
    });

    try {
      await ref.read(selectedCityProvider.notifier).set(slug);
      
      // Trigger initial sync
      ref.read(syncServiceProvider).syncAll(slug).ignore();
      
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
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
      hint: 'Нажмите чтобы выбрать этот город',
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
