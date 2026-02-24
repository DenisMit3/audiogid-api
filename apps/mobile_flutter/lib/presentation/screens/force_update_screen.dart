import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateScreen extends StatelessWidget {
  final String storeUrl;
  final String message;
  final String currentVersion;
  final String minVersion;

  const ForceUpdateScreen({
    super.key,
    required this.storeUrl,
    required this.message,
    required this.currentVersion,
    required this.minVersion,
  });

  Future<void> _openStore() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Иконка обновления
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Заголовок
              Text(
                'Требуется обновление',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Сообщение
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Информация о версиях
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildVersionRow(
                      context,
                      'Ваша версия:',
                      minVersion,
                      Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildVersionRow(
                      context,
                      'Требуется:',
                      currentVersion,
                      Colors.green,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Кнопка обновления
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _openStore,
                  icon: const Icon(Icons.download),
                  label: const Text(
                    'Обновить приложение',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Подсказка
              Text(
                'После обновления приложение запустится автоматически',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionRow(
    BuildContext context,
    String label,
    String version,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'v$version',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
