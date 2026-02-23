import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';

/// Экран обучения с PageView
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.location_on_outlined,
      title: 'Геолокация',
      description: 'Приложение определит ваш город автоматически и покажет '
          'ближайшие туры. Вы также можете выбрать город вручную.',
      tip: 'Разрешите доступ к геолокации для лучшего опыта',
    ),
    _OnboardingPageData(
      icon: Icons.headphones_outlined,
      title: 'Аудиогид',
      description: 'Слушайте интересные истории о местах вокруг вас. '
          'Аудио запускается автоматически, когда вы приближаетесь к точке.',
      tip: 'Используйте наушники для комфортного прослушивания',
    ),
    _OnboardingPageData(
      icon: Icons.download_outlined,
      title: 'Офлайн режим',
      description: 'Скачайте туры заранее и пользуйтесь ими без интернета. '
          'Идеально для путешествий!',
      tip: 'Скачивайте туры по Wi-Fi для экономии трафика',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Фон
          _OnboardingBackground(
            colorScheme: colorScheme,
            currentPage: _currentPage,
            totalPages: _pages.length,
          ),
          
          // Контент
          SafeAreaWrapper(
            child: Column(
              children: [
                // Кнопка пропустить
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Пропустить',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      HapticFeedback.selectionClick();
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPage(data: _pages[index]);
                    },
                  ),
                ),
                
                // Индикаторы и кнопка
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      // Индикаторы страниц
                      _PageIndicators(
                        currentPage: _currentPage,
                        totalPages: _pages.length,
                        colorScheme: colorScheme,
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Кнопка действия
                      _buildActionButton(context, colorScheme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ColorScheme colorScheme) {
    final isLastPage = _currentPage == _pages.length - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLastPage ? _finishOnboarding : _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage ? 'Начать' : 'Далее',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              isLastPage ? Icons.check : Icons.arrow_forward,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    _pageController.nextPage(
      duration: AppDurations.normal,
      curve: AppCurves.emphasized,
    );
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.lightImpact();
    
    // Отмечаем onboarding как пройденный
    await ref.read(onboardingCompletedProvider.notifier).complete();
    
    if (mounted) {
      context.go('/city-select');
    }
  }
}

/// Данные для страницы обучения
class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final String tip;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.tip,
  });
}

/// Страница обучения
class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ResponsivePadding(
      child: ResponsiveContainer(
        maxWidth: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            
            // Иконка
            AnimatedContent(
              delay: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    size: context.responsive(
                      smallPhone: 56.0,
                      phone: 72.0,
                      tablet: 88.0,
                    ),
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            const Spacer(flex: 1),
            
            // Заголовок
            AnimatedContent(
              delay: const Duration(milliseconds: 200),
              child: AccessibleHeader(
                text: data.title,
                level: 1,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Описание
            AnimatedContent(
              delay: const Duration(milliseconds: 300),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Подсказка
            AnimatedContent(
              delay: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        data.tip,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

/// Фон для onboarding с анимированным градиентом
class _OnboardingBackground extends StatelessWidget {
  final ColorScheme colorScheme;
  final int currentPage;
  final int totalPages;

  const _OnboardingBackground({
    required this.colorScheme,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    // Разные цвета для разных страниц
    final colors = [
      [
        colorScheme.primaryContainer.withOpacity(0.4),
        colorScheme.surface,
        colorScheme.secondaryContainer.withOpacity(0.3),
      ],
      [
        colorScheme.secondaryContainer.withOpacity(0.4),
        colorScheme.surface,
        colorScheme.primaryContainer.withOpacity(0.3),
      ],
      [
        colorScheme.tertiaryContainer.withOpacity(0.4),
        colorScheme.surface,
        colorScheme.primaryContainer.withOpacity(0.3),
      ],
    ];

    return AnimatedContainer(
      duration: AppDurations.normal,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[currentPage % colors.length],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _OnboardingPatternPainter(
          color: colorScheme.primary.withOpacity(0.04),
          pageProgress: currentPage / (totalPages - 1),
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Паттерн для фона onboarding
class _OnboardingPatternPainter extends CustomPainter {
  final Color color;
  final double pageProgress;

  _OnboardingPatternPainter({
    required this.color,
    required this.pageProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Декоративные элементы, которые немного двигаются
    final offset = pageProgress * 30;

    final circles = [
      Offset(size.width * 0.1 + offset, size.height * 0.12),
      Offset(size.width * 0.88 - offset, size.height * 0.08),
      Offset(size.width * 0.92 - offset * 0.5, size.height * 0.35),
      Offset(size.width * 0.08 + offset * 0.5, size.height * 0.55),
      Offset(size.width * 0.85 - offset, size.height * 0.8),
      Offset(size.width * 0.2 + offset, size.height * 0.9),
    ];

    final radii = [35.0, 25.0, 45.0, 30.0, 40.0, 20.0];

    for (var i = 0; i < circles.length; i++) {
      canvas.drawCircle(circles[i], radii[i], paint);
    }

    // Волнистые линии
    final pathPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height * 0.25 + offset);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2 + offset,
      size.width * 0.5, size.height * 0.28 + offset,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.36 + offset,
      size.width, size.height * 0.3 + offset,
    );
    canvas.drawPath(path, pathPaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.75 - offset);
    path2.quadraticBezierTo(
      size.width * 0.3, size.height * 0.7 - offset,
      size.width * 0.55, size.height * 0.78 - offset,
    );
    path2.quadraticBezierTo(
      size.width * 0.8, size.height * 0.85 - offset,
      size.width, size.height * 0.72 - offset,
    );
    canvas.drawPath(path2, pathPaint);
  }

  @override
  bool shouldRepaint(covariant _OnboardingPatternPainter oldDelegate) {
    return oldDelegate.pageProgress != pageProgress;
  }
}

/// Индикаторы страниц
class _PageIndicators extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ColorScheme colorScheme;

  const _PageIndicators({
    required this.currentPage,
    required this.totalPages,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: AppDurations.fast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}
