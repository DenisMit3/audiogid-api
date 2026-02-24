import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';

/// Первый экран приложения - приветствие с выбором обучения
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      begin: const Offset(0, 0.15),
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

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Фон - градиент с паттерном путешествий
          _TravelBackground(colorScheme: colorScheme),

          // Контент
          SafeAreaWrapper(
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

                        // Логотип/иконка
                        AnimatedContent(
                          delay: const Duration(milliseconds: 100),
                          child: _buildLogo(context, colorScheme),
                        ),

                        SizedBox(
                            height: context.responsive(
                          smallPhone: AppSpacing.lg,
                          phone: AppSpacing.xl,
                          tablet: AppSpacing.xxl,
                        )),

                        // Приветственный текст
                        AnimatedContent(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            children: [
                              AccessibleHeader(
                                text: 'Аудиогид',
                                level: 1,
                                style: textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Ваш персональный гид\nпо интересным местам',
                                textAlign: TextAlign.center,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Кнопка "Начать путешествие" (с обучением)
                        AnimatedContent(
                          delay: const Duration(milliseconds: 300),
                          child: _WelcomeButton(
                            title: 'Начать путешествие',
                            subtitle: 'Краткое обучение за 1 минуту',
                            icon: Icons.explore_outlined,
                            isPrimary: true,
                            onTap: () => _startWithOnboarding(),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Кнопка "Пропустить"
                        AnimatedContent(
                          delay: const Duration(milliseconds: 400),
                          child: _WelcomeButton(
                            title: 'Уже знаю как пользоваться',
                            subtitle: 'Перейти к турам',
                            icon: Icons.arrow_forward_outlined,
                            isPrimary: false,
                            onTap: () => _skipOnboarding(),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Версия приложения
                        AnimatedContent(
                          delay: const Duration(milliseconds: 500),
                          child: Text(
                            'Версия 1.0',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.headphones_outlined,
        size: context.responsive(
          smallPhone: 64.0,
          phone: 80.0,
          tablet: 100.0,
        ),
        color: colorScheme.primary,
        semanticLabel: 'Логотип Аудиогида',
      ),
    );
  }

  Future<void> _startWithOnboarding() async {
    HapticFeedback.lightImpact();
    context.go('/onboarding');
  }

  Future<void> _skipOnboarding() async {
    HapticFeedback.lightImpact();

    // Отмечаем onboarding как пройденный
    await ref.read(onboardingCompletedProvider.notifier).complete();

    if (mounted) {
      context.go('/city-select');
    }
  }
}

/// Фон с паттерном для путешественников
class _TravelBackground extends StatelessWidget {
  final ColorScheme colorScheme;

  const _TravelBackground({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.4),
            colorScheme.surface,
            colorScheme.tertiaryContainer.withOpacity(0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _TravelPatternPainter(
          color: colorScheme.primary.withOpacity(0.05),
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Паттерн с иконками путешествий
class _TravelPatternPainter extends CustomPainter {
  final Color color;

  _TravelPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Рисуем декоративные круги разного размера
    final circles = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.4),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.75),
      Offset(size.width * 0.25, size.height * 0.85),
    ];

    final radii = [40.0, 30.0, 50.0, 35.0, 45.0, 25.0];

    for (var i = 0; i < circles.length; i++) {
      canvas.drawCircle(circles[i], radii[i], paint);
    }

    // Декоративные линии-пути
    final pathPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.45,
      size.width,
      size.height * 0.4,
    );
    canvas.drawPath(path, pathPaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.65,
      size.width * 0.6,
      size.height * 0.72,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.78,
      size.width,
      size.height * 0.68,
    );
    canvas.drawPath(path2, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Кнопка на экране приветствия
class _WelcomeButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _WelcomeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_WelcomeButton> createState() => _WelcomeButtonState();
}

class _WelcomeButtonState extends State<_WelcomeButton>
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
      end: 0.97,
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

    final bgColor = widget.isPrimary
        ? colorScheme.primary
        : colorScheme.surface.withOpacity(0.9);
    final fgColor =
        widget.isPrimary ? colorScheme.onPrimary : colorScheme.onSurface;
    final subtitleColor = widget.isPrimary
        ? colorScheme.onPrimary.withOpacity(0.8)
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      label: '${widget.title}, ${widget.subtitle}',
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
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: widget.isPrimary
                  ? null
                  : Border.all(color: colorScheme.outlineVariant),
              boxShadow: widget.isPrimary
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Иконка
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: widget.isPrimary
                        ? colorScheme.onPrimary.withOpacity(0.2)
                        : colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isPrimary
                        ? colorScheme.onPrimary
                        : colorScheme.primary,
                    size: 24,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Текст
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: textTheme.titleMedium?.copyWith(
                          color: fgColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Стрелка
                Icon(
                  Icons.chevron_right,
                  color: widget.isPrimary
                      ? colorScheme.onPrimary.withOpacity(0.7)
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
