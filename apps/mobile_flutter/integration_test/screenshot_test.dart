import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_flutter/main.dart' as app;

// Creates screenshots for Store Submission (Task 1.1)
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('generate_store_screenshots', (WidgetTester tester) async {
    // 1. App Start (Screenshot 1: City Select?)
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Wait for data to load
    await tester.pumpAndSettle();
    
    // Screenshot: City Selection / Home
    if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('01_home_screen');
    }

    // 2. Click on a city (assuming 'Kaliningrad' or first item is visible)
    // Finding by Key is safest if Keys exist, otherwise by text or type.
    // Let's assume we see 'Калининград' text.
    final cityFinder = find.text('Калининград');
    if (cityFinder.evaluate().isNotEmpty) {
      await tester.tap(cityFinder);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Screenshot: Tours List
      if (Platform.isAndroid) {
         await binding.takeScreenshot('02_tours_list');
      }
      
      // 3. Click on a Tour
      final tourFinder = find.byType(Card).first;
      if (tourFinder.evaluate().isNotEmpty) {
        await tester.tap(tourFinder);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Screenshot: Tour Detail
          if (Platform.isAndroid) {
             await binding.takeScreenshot('03_tour_detail');
          }
      }
    }
  });
}
