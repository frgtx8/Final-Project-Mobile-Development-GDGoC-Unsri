import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:efooty_tactics/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('eFootyTactics AI - End to End Integration Test', () {
    testWidgets('Full app navigation and feature workflow test',
        (WidgetTester tester) async {
      // 1. Launch the application
      await tester.pumpWidget(
        const ProviderScope(
          child: EFootyTacticsApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Verify Home Screen (Squad Builder) is displayed
      expect(find.text('ANALISIS SINERGI SKUAD (AI DOCTOR)'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // 3. Navigate to Database Tab
      await tester.tap(find.text('Database'));
      await tester.pumpAndSettle();
      expect(find.text('DATABASE PEMAIN eFOOTBALL'), findsOneWidget);

      // 4. Navigate to AI Scout Tab
      await tester.tap(find.text('AI Scout'));
      await tester.pumpAndSettle();
      expect(find.text('AI PLAYER SCOUT & BUILDS'), findsOneWidget);

      // 5. Navigate to Community Tab
      await tester.tap(find.text('Komunitas'));
      await tester.pumpAndSettle();
      expect(find.text('COMMUNITY META TACTICS'), findsOneWidget);

      // 6. Navigate to Koleksi Tab
      await tester.tap(find.text('Koleksi'));
      await tester.pumpAndSettle();
      expect(find.text('KOLEKSI SKUAD SAYA'), findsOneWidget);

      // 7. Return to Squad Builder Tab
      await tester.tap(find.text('Squad'));
      await tester.pumpAndSettle();
      expect(find.text('ANALISIS SINERGI SKUAD (AI DOCTOR)'), findsOneWidget);
    });
  });
}
