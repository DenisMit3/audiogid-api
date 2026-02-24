import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/error/error_utils.dart';

/// Empty state widget for when there's no content
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding * 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with subtle background
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: customIcon ??
                  Icon(
                    icon,
                    size: 64,
                    color: colorScheme.primary.withOpacity(0.7),
                    semanticLabel: title,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              semanticsLabel: title,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Factory for empty search results
  factory EmptyStateWidget.searchResults({String? query}) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'Ничего не найдено',
      subtitle: query != null
          ? 'По запросу "$query" ничего не найдено'
          : 'Попробуйте изменить параметры поиска',
    );
  }

  /// Factory for empty favorites
  factory EmptyStateWidget.favorites({VoidCallback? onExplore}) {
    return EmptyStateWidget(
      icon: Icons.favorite_border_outlined,
      title: 'Нет избранного',
      subtitle: 'Добавляйте интересные места и туры в избранное',
      actionLabel: 'Найти места',
      onAction: onExplore,
    );
  }

  /// Factory for empty tours
  factory EmptyStateWidget.tours({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icons.route_outlined,
      title: 'Туры не найдены',
      subtitle: 'В этом регионе пока нет доступных туров',
      actionLabel: 'Обновить',
      onAction: onRefresh,
    );
  }

  /// Factory for empty POIs
  factory EmptyStateWidget.pois({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icons.place_outlined,
      title: 'Места не найдены',
      subtitle: 'В этом регионе пока нет доступных мест',
      actionLabel: 'Обновить',
      onAction: onRefresh,
    );
  }

  /// Factory for no location permission
  factory EmptyStateWidget.noLocation({VoidCallback? onEnable}) {
    return EmptyStateWidget(
      icon: Icons.location_off_outlined,
      title: 'Нет доступа к геолокации',
      subtitle: 'Разрешите доступ к местоположению для поиска мест рядом',
      actionLabel: 'Разрешить',
      onAction: onEnable,
    );
  }

  /// Factory for offline mode
  factory EmptyStateWidget.offline({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.cloud_off_outlined,
      title: 'Нет подключения',
      subtitle: 'Проверьте интернет-соединение и попробуйте снова',
      actionLabel: 'Повторить',
      onAction: onRetry,
    );
  }

  /// Factory for empty downloads
  factory EmptyStateWidget.downloads({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.download_outlined,
      title: 'Нет загрузок',
      subtitle: 'Скачайте контент для офлайн-доступа',
      actionLabel: 'Выбрать контент',
      onAction: onBrowse,
    );
  }
}

/// Error state widget with retry option
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? errorCode;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    this.title = 'Произошла ошибка',
    this.subtitle,
    this.errorCode,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding * 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with red background
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: colorScheme.error,
                semanticLabel: 'Ошибка',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Error code
            if (errorCode != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Код: $errorCode',
                  style: textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Попробовать снова'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Factory for network errors
  factory ErrorStateWidget.network({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      icon: Icons.wifi_off_outlined,
      title: 'Ошибка сети',
      subtitle:
          'Не удалось подключиться к серверу. Проверьте интернет-соединение.',
      onRetry: onRetry,
    );
  }

  /// Factory for server errors
  factory ErrorStateWidget.server({String? errorCode, VoidCallback? onRetry}) {
    return ErrorStateWidget(
      icon: Icons.cloud_off_outlined,
      title: 'Ошибка сервера',
      subtitle: 'Сервер временно недоступен. Попробуйте позже.',
      errorCode: errorCode,
      onRetry: onRetry,
    );
  }

  /// Factory for timeout errors
  factory ErrorStateWidget.timeout({VoidCallback? onRetry}) {
    return ErrorStateWidget(
      icon: Icons.timer_off_outlined,
      title: 'Время ожидания истекло',
      subtitle: 'Запрос занял слишком много времени. Попробуйте снова.',
      onRetry: onRetry,
    );
  }

  /// Factory for not found errors
  factory ErrorStateWidget.notFound({String? item}) {
    return ErrorStateWidget(
      icon: Icons.search_off_outlined,
      title: '${item ?? 'Элемент'} не найден',
      subtitle: 'Возможно, он был удалён или перемещён.',
    );
  }

  /// Factory for permission errors
  factory ErrorStateWidget.permission(
      {String? permission, VoidCallback? onSettings}) {
    return ErrorStateWidget(
      icon: Icons.lock_outline,
      title: 'Нет доступа',
      subtitle: permission != null
          ? 'Требуется разрешение: $permission'
          : 'У вас нет прав для просмотра этого контента.',
      onRetry: onSettings,
    );
  }

  /// Factory for generic errors with message
  factory ErrorStateWidget.generic({
    required dynamic error,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      title: 'Произошла ошибка',
      subtitle: error is String ? error : ErrorUtils.getErrorMessage(error),
      onRetry: onRetry,
    );
  }
}

/// Loading overlay with message
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final double? progress;

  const LoadingOverlay({
    super.key,
    this.message,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: Colors.black45,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress && progress != null)
                CircularProgressIndicator(value: progress)
              else
                const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pull-to-refresh wrapper with proper safe area handling
class RefreshableContent extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;

  const RefreshableContent({
    super.key,
    required this.child,
    required this.onRefresh,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: 40 + context.safeAreaPadding.top,
      child: child,
    );
  }
}

/// Animated content appearance wrapper
class AnimatedContent extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;

  const AnimatedContent({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppDurations.normal,
    this.curve = AppCurves.emphasized,
    this.slideOffset = const Offset(0, 0.1),
  });

  @override
  State<AnimatedContent> createState() => _AnimatedContentState();
}

class _AnimatedContentState extends State<AnimatedContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
