import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/services/share_service.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  bool _isLoading = false;

  Future<void> _handleSos() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
            throw Exception("Нет доступа к геолокации");
        }
      }
      
      final position = await Geolocator.getCurrentPosition();
      
      await ref.read(shareServiceProvider).sendSos(position.latitude, position.longitude);
      
      if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Открываю SMS...')));
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleShareTrip() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception("Нет доступа к геолокации");
        }
      }

      final position = await Geolocator.getCurrentPosition();
      await ref.read(shareServiceProvider).shareTrip(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) {
          setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS & Sharing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _handleSos,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                  ]
                ),
                alignment: Alignment.center,
                child: _isLoading 
                   ? const CircularProgressIndicator(color: Colors.white)
                   : const Text("SOS", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.share_location),
              label: const Text('Поделиться маршрутом (1 час)'),
              onPressed: _isLoading ? null : _handleShareTrip,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
             const SizedBox(height: 20),
            TextButton(
                onPressed: () {
                     context.push('/trusted_contacts');
                },
                child: const Text("Настроить контакты")
            )
          ],
        ),
      ),
    );
  }
}
