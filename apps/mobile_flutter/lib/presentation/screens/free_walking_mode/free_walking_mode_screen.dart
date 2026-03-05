import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/data/services/free_walking_service.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:mobile_flutter/design_system/tokens/colors.dart';
import 'package:mobile_flutter/design_system/tokens/spacing.dart';
import 'package:mobile_flutter/design_system/tokens/radius.dart';
import 'package:mobile_flutter/design_system/tokens/motion.dart';
import 'package:mobile_flutter/design_system/components/buttons/buttons.dart';
import 'package:mobile_flutter/presentation/widgets/common/glass_widgets.dart';
import 'package:go_router/go_router.dart';

class FreeWalkingModeScreen extends ConsumerWidget {
  const FreeWalkingModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(freeWalkingServiceProvider);
    final controller = ref.read(freeWalkingServiceProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          'Режим прогулки',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // 1. Visual Status Area
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRadar(state.isActive, colorScheme),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    state.statusMessage ??
                        (state.isActive
                            ? 'Ищем интересные места...'
                            : 'Готов к прогулке'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: state.isActive
                          ? AppColors.accentPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Recent Discovery / History
          if (state.recentActivity.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Недавние находки',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: state.recentActivity.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final poi = state.recentActivity[index];
                  return _buildHistoryItem(context, poi);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ] else
            const Spacer(flex: 1),

          // 3. Settings Panel
          GlassCard(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.bottomSheet),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSlider(
                  context: context,
                  label: 'Радиус поиска',
                  value: state.activationRadius,
                  min: 20,
                  max: 200,
                  divisions: 9,
                  unit: 'м',
                  onChanged: state.isActive
                      ? null
                      : (v) => controller.updateSettings(radius: v),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildSlider(
                  context: context,
                  label: 'Пауза между местами',
                  value: state.cooldownMinutes.toDouble(),
                  min: 1,
                  max: 60,
                  divisions: 59,
                  unit: 'мин',
                  onChanged: state.isActive
                      ? null
                      : (v) => controller.updateSettings(cooldown: v.toInt()),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Start/Stop Button
                PrimaryButton(
                  label: state.isActive
                      ? 'Остановить прогулку'
                      : 'Начать прогулку',
                  icon: state.isActive
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  height: 56,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (state.isActive) {
                      controller.stop();
                    } else {
                      controller.start();
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadar(bool isActive, ColorScheme colors) {
    return AnimatedContainer(
      duration: AppDurations.standard,
      curve: AppCurves.easeOut,
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppColors.accentPrimary.withOpacity(0.1)
            : AppColors.bgSecondary,
        border: Border.all(
          color: isActive ? AppColors.accentPrimary : AppColors.glassBorder,
          width: isActive ? 4 : 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.accentPrimary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ]
            : [],
      ),
      child: Center(
        child: Icon(
          Icons.directions_walk_rounded,
          size: 64,
          color: isActive ? AppColors.accentPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double>? onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text('${value.toInt()} $unit',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: '${value.toInt()} $unit',
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, Poi poi) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/poi/${poi.id}');
      },
      child: GlassCard(
        width: 240,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.card),
                bottomLeft: Radius.circular(AppRadius.card),
              ),
              child: Container(
                width: 80,
                height: double.infinity,
                color: AppColors.bgSecondary,
                child: Center(
                  child: poi.previewAudioUrl != null
                      ? Icon(Icons.music_note, color: AppColors.accentPrimary, size: 32)
                      : Icon(Icons.place, color: AppColors.textSecondary, size: 32),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.titleRu,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Только что',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
