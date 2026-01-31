import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          // Scanner Overlay Map
          CustomPaint(
             painter: ScannerOverlayPainter(borderColor: Theme.of(context).primaryColor),
             child: Container(),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Поиск экспоната...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Наведите камеру на QR-код\nДля музеев и уличных маршрутов',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCode(String code) async {
    await HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);
    
    try {
      // Step 1: Try to extract POI/Tour ID from URL patterns (Deep Link parsing)
      String? targetType;
      String? targetId;
      
      try {
        final uri = Uri.parse(code);
        if (uri.host.contains('audiogid') || uri.scheme == 'audiogid') {
           final segments = uri.pathSegments;
           if (segments.contains('poi') && segments.length > segments.indexOf('poi') + 1) {
             targetType = 'poi';
             targetId = segments[segments.indexOf('poi') + 1];
           } else if (segments.contains('tour') && segments.length > segments.indexOf('tour') + 1) {
             targetType = 'tour';
             targetId = segments[segments.indexOf('tour') + 1];
           }
        }
      } catch (_) {}

      // Step 2: If no direct URL match, try QR mapping API (or offline lookup)
      if (targetType == null || targetId == null) {
        final qrRepo = ref.read(qrMappingRepositoryProvider);
        // This now handles API -> Cache -> Local POI Table
        final mapping = await qrRepo.resolveCode(code);
        
        if (mapping != null) {
          targetType = mapping.targetType;
          targetId = mapping.targetId;
        }
      }

      // Step 3: Navigate based on resolved target
      if (targetType != null && targetId != null) {
        if (mounted) {
           // Success feedback
           await HapticFeedback.heavyImpact();
           
           if (targetType == 'poi') {
            context.push('/poi/$targetId', extra: {'autoplay': true});
          } else if (targetType == 'tour') {
            context.push('/tour/$targetId');
          }
        }
      } else {
        // Unknown code
        if (mounted) {
          await HapticFeedback.vibrate();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Код не найден: $code\nПроверьте подключение к интернету.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(label: 'ОК', textColor: Colors.white, onPressed: () {}),
            ),
          );
          await Future.delayed(const Duration(seconds: 2)); // cooldown
          if (mounted) setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;

  ScannerOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Cutout rect
    final cutoutSize = size.width * 0.7;
    final left = (size.width - cutoutSize) / 2;
    final top = (size.height - cutoutSize) / 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, cutoutSize, cutoutSize), 
      const Radius.circular(20)
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(rect),
      ),
      paint,
    );

    // Borders
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final cornerSize = 30.0;
    final path = Path();
    
    // Top Left
    path.moveTo(left, top + cornerSize);
    path.lineTo(left, top);
    path.lineTo(left + cornerSize, top);

    // Top Right
    path.moveTo(left + cutoutSize - cornerSize, top);
    path.lineTo(left + cutoutSize, top);
    path.lineTo(left + cutoutSize, top + cornerSize);

    // Bottom Right
    path.moveTo(left + cutoutSize, top + cutoutSize - cornerSize);
    path.lineTo(left + cutoutSize, top + cutoutSize);
    path.lineTo(left + cutoutSize - cornerSize, top + cutoutSize);

    // Bottom Left
    path.moveTo(left + cornerSize, top + cutoutSize);
    path.lineTo(left, top + cutoutSize);
    path.lineTo(left, top + cutoutSize - cornerSize);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  
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
