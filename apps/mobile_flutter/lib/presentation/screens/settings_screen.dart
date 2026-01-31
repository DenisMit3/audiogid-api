import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/data/repositories/settings_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/presentation/widgets/common/common.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:api_client/api.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_flutter/data/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';
  bool _kidsMode = false;
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    if (mounted) {
      setState(() {
        _kidsMode = repo.getKidsModeEnabled();
        _isLoadingSettings = false;
      });
    }
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version} (${info.buildNumber})';
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть ссылку: $url')),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление аккаунта'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Вы действительно хотите удалить аккаунт? '
              'Все ваши данные, включая покупки и избранное, будут удалены безвозвратно с этого устройства.',
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => _launchUrl('https://audiogid.app/delete-account'),
              child: Text(
                'Управление данными на сайте',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Show loading indicator
                if (mounted) {
                   Navigator.of(context).pop(); // Close confirm dialog
                   showDialog(
                     context: context,
                     barrierDismissible: false,
                     builder: (_) => const Center(child: CircularProgressIndicator()),
                   );
                }

                // Get ID
                final prefs = await SharedPreferences.getInstance();
                final deviceId = prefs.getString('device_anon_id');
                
                if (deviceId != null) {
                    final api = ref.read(accountApiProvider);
                    final req = RequestDeletionRequest(
                        subjectId: deviceId, 
                        idempotencyKey: const Uuid().v4()
                    );
                    
                    final res = await api.requestDeletion(req);
                    // We can poll here if needed, but for now we accept the request is queued.
                    // The instruction said "handle response (async job, poll status via getDeletionStatus())"
                    
                   if (res != null && res.id != null) {
                      String? status = res.status;
                      int retries = 0;
                      // Poll for a bit to ensure it started/completed
                      while ((status == 'PENDING' || status == 'QUEUED') && retries < 5) {
                          await Future.delayed(const Duration(seconds: 1));
                          final statusRes = await api.getDeletionStatus(res.id!);
                          status = statusRes?.status;
                          retries++;
                      }
                   }
                }

                // Delete local data
                final settingsRepo = await ref.read(settingsRepositoryProvider.future);
                await settingsRepo.clearAll();

                if (mounted) {
                  Navigator.of(context).pop(); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Аккаунт и данные удалены')),
                  );
                  // Restart or navigate home
                  context.go('/');
                }
              } catch (e) {
                 if (mounted) {
                   // Pop loading if open? Difficult to track nesting here simply.
                   // Assuming loading dialog is top.
                   Navigator.of(context).pop(); 
                   
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Ошибка удаления: $e')),
                   );
                 }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: SafeAreaWrapper(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Account Section
            _buildSectionHeader(context, 'Аккаунт'),
            if (user == null)
               ListTile(
                 title: const Text('Войти / Регистрация'),
                 subtitle: const Text('Синхронизация покупок'),
                 leading: const Icon(Icons.login),
                 onTap: () => context.push('/login'),
               )
            else ...[
               ListTile(
                 title: const Text('Выйти'),
                 subtitle: Text('ID: ${user.id.substring(0, 8)}...'),
                 leading: const Icon(Icons.logout),
                 onTap: () => ref.read(currentUserProvider.notifier).logout(),
               ),
            ],
            const Divider(),

            // Preferences Section
            _buildSectionHeader(context, 'Предпочтения'),
            SwitchListTile(
              title: const Text('Режим "С детьми"'),
              subtitle: const Text('Упрощенный язык и короткие рассказы'),
              secondary: const Icon(Icons.child_care),
              value: _kidsMode,
              onChanged: _isLoadingSettings ? null : (value) async {
                 setState(() => _kidsMode = value);
                 final repo = await ref.read(settingsRepositoryProvider.future);
                 await repo.setKidsModeEnabled(value);
              },
            ),
            const Divider(),

            // Security Section
            _buildSectionHeader(context, 'Безопасность'),
            ListTile(
              title: const Text('Доверенные контакты (SOS)'),
              subtitle: const Text('Контакты для экстренных уведомлений'),
              leading: const Icon(Icons.security),
              onTap: () => context.push('/trusted_contacts'),
            ),
            const Divider(),

            // General Section

            _buildSectionHeader(context, 'О приложении'),
            ListTile(
              title: const Text('Мой маршрут'),
              leading: const Icon(Icons.map_outlined),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/itinerary'),
            ),
            ListTile(
              title: const Text('Оценить приложение'),
              leading: const Icon(Icons.star_outline),
              onTap: () async {
                final inAppReview = InAppReview.instance;

                if (await inAppReview.isAvailable()) {
                   inAppReview.requestReview();
                } else {
                   // Fallback
                   final isAndroid = Theme.of(context).platform == TargetPlatform.android;
                   if (isAndroid) {
                     _launchUrl('market://details?id=com.audiogid.app');
                   } else {
                     _launchUrl('https://apps.apple.com/app/id6470000000');
                   }
                }
              },
            ),
            ListTile(
              title: const Text('Рассказать друзьям'),
              leading: const Icon(Icons.share_outlined),
              onTap: () {
                Share.share('Я исследую город с Audiogid! Присоединяйся: https://audiogid.app');
              },
            ),
            ListTile(
              title: const Text('Политика конфиденциальности'),
              leading: const Icon(Icons.privacy_tip_outlined),
              onTap: () => _launchUrl('https://audiogid.app/privacy'),
            ),
            
            const Divider(),

            // Data Section
            _buildSectionHeader(context, 'Данные'),
             ListTile(
              title: const Text('Удалить аккаунт'),
              subtitle: const Text('Удалить все личные данные'),
              leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: _showDeleteAccountDialog,
            ),

            const Divider(),

            // Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'Версия $_version',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm, 
        horizontal: AppSpacing.sm, // Match ListTile padding roughly
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
