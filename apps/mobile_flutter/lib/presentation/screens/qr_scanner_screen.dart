import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/data/repositories/qr_mapping_repository.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> 
    with RouteAware, WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to detect when we return from navigation
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from a pushed route
    // Reset processing state so scanner reactivates
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать QR'),
        actions: [
          IconButton(
            icon: Icon(controller.torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isProcessing) return;
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Распознавание кода...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Наведите камеру на QR-код экспоната',
                style: TextStyle(color: Colors.white, fontSize: 16, backgroundColor: Colors.black45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCode(String code) async {
    setState(() => _isProcessing = true);
    
    try {
      // Step 1: Try to extract POI/Tour ID from URL patterns
      String? targetType;
      String? targetId;
      
      Uri? uri = Uri.tryParse(code);

      if (uri != null) {
        if (uri.host == 'audiogid.app' || uri.host == 'audiogid.ru') {
          // Path parsing for direct URLs
          final segments = uri.pathSegments;
          if (segments.length >= 2 && segments[0] == 'poi') {
            targetType = 'poi';
            targetId = segments[1];
          } else if (segments.length >= 2 && segments[0] == 'tour') {
            targetType = 'tour';
            targetId = segments[1];
          } else if (segments.length >= 3 && segments[0] == 'dl' && segments[1] == 'poi') {
            targetType = 'poi';
            targetId = segments[2];
          } else if (segments.length >= 3 && segments[0] == 'dl' && segments[1] == 'tour') {
            targetType = 'tour';
            targetId = segments[2];
          }
        } else if (uri.scheme == 'poi') {
          targetType = 'poi';
          targetId = uri.path;
        } else if (uri.scheme == 'tour') {
          targetType = 'tour';
          targetId = uri.path;
        }
      }

      // Step 2: If no direct URL match, try QR mapping API
      if (targetType == null || targetId == null) {
        final qrRepo = ref.read(qrMappingRepositoryProvider);
        final mapping = await qrRepo.resolveCode(code);
        
        if (mapping != null) {
          targetType = mapping.targetType;
          targetId = mapping.targetId;
        }
      }

      // Step 3: Navigate based on resolved target
      if (targetType != null && targetId != null) {
        if (targetType == 'poi') {
          // Navigate to POI and Autoplay (Museum Mode)
          if (mounted) {
            context.push('/poi/$targetId', extra: {'autoplay': true});
          }
        } else if (targetType == 'tour') {
          // Navigate to Tour
          if (mounted) {
            context.push('/tour/$targetId');
          }
        }
      } else {
        // Unknown code
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Неизвестный код: $code'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
          // Reset processing after showing error so user can try again
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      // Handle API errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при распознавании: $e'),
            action: SnackBarAction(
              label: 'Повторить',
              onPressed: () => setState(() => _isProcessing = false),
            ),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    controller.dispose();
    super.dispose();
  }
}

/// Global route observer for detecting navigation events
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
