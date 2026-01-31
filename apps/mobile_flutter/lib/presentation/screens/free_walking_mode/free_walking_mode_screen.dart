import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/domain/entities/poi.dart';
import 'package:mobile_flutter/data/services/free_walking_service.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:go_router/go_router.dart';

class FreeWalkingModeScreen extends ConsumerWidget {
  const FreeWalkingModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(freeWalkingServiceProvider);
    final controller = ref.read(freeWalkingServiceProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Режим прогулки'),
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
                    state.statusMessage ?? (state.isActive ? 'Ищем интересные места...' : 'Готов к прогулке'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: state.isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
                child: Text('Недавние находки', style: Theme.of(context).textTheme.titleSmall),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: state.recentActivity.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
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
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
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
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (state.isActive) {
                        controller.stop();
                      } else {
                        controller.start();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isActive ? colorScheme.error : colorScheme.primary,
                      foregroundColor: state.isActive ? colorScheme.onError : colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    icon: Icon(state.isActive ? Icons.stop_rounded : Icons.play_arrow_rounded),
                    label: Text(
                      state.isActive ? 'Остановить прогулку' : 'Начать прогулку',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
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
      duration: const Duration(milliseconds: 500),
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? colors.primaryContainer.withOpacity(0.2) : colors.surfaceVariant,
        border: Border.all(
          color: isActive ? colors.primary : colors.outline.withOpacity(0.5),
          width: isActive ? 4 : 2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ) 
        ] : [],
      ),
      child: Center(
        child: Icon(
          Icons.directions_walk_rounded,
          size: 64,
          color: isActive ? colors.primary : colors.onSurfaceVariant,
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
            Text('${value.toInt()} $unit', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/poi/${poi.id}'),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: 80,
                height: double.infinity,
                color: colorScheme.surfaceVariant,
                child: poi.previewAudioUrl != null 
                    ? Icon(Icons.music_note, color: colorScheme.primary)
                    : Icon(Icons.place, color: colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.titleRu,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Только что',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.secondary),
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
