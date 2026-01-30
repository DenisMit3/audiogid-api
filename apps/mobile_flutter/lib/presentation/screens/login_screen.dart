import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (prev, next) {
       if (next is AsyncData && next.value != null) {
          if (context.canPop()) {
              context.pop();
          } else {
              context.go('/');
          }
       }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Добро пожаловать',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Введите номер телефона для входа'),
            const SizedBox(height: 32),
            if (!_codeSent) ...[
                TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                        labelText: 'Телефон',
                        hintText: '+7 900 000 00 00',
                        border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: _isLoading ? null : _sendCode,
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('Получить код'),
                ),
            ] else ...[
                TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                        labelText: 'Код из СМС',
                        border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: _isLoading ? null : _verifyCode,
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text('Войти'),
                ),
                TextButton(
                    onPressed: () => setState(() => _codeSent = false),
                )
            ],
            const SizedBox(height: 24),
            const Row(children: [
              Expanded(child: Divider()), 
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("ИЛИ")), 
              Expanded(child: Divider())
            ]),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                 // TODO: Implement Telegram Widget WebView or Deep Link flow
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Telegram Login requires Bot/Web integration")));
              },
              icon: const Icon(Icons.send), // Placeholder for Telegram icon
              label: const Text("Войти через Telegram"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
      setState(() => _isLoading = true);
      try {
          await ref.read(currentUserProvider.notifier).loginWithSms(_phoneController.text);
          setState(() {
              _codeSent = true;
          });
      } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      } finally {
          if (mounted) setState(() => _isLoading = false);
      }
  }

  Future<void> _verifyCode() async {
       setState(() => _isLoading = true);
      try {
          await ref.read(currentUserProvider.notifier).verifySms(_phoneController.text, _otpController.text);
          // Navigation handled by listener
      } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      } finally {
          if (mounted) setState(() => _isLoading = false);
      }
  }
}
