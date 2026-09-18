import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/auth/presentation/auth_screen.dart';

void main() {
  group('AuthScreen UI & Form Tests', () {
    testWidgets('Renders Login form by default and toggles to Sign Up',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Default is Login
      expect(find.text('LOGIN SUPABASE'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Ulangi / Konfirmasi Password'), findsNothing);

      // Toggle to Sign Up
      final toggleButton = find.textContaining('Buat akun sekarang');
      expect(toggleButton, findsOneWidget);
      await tester.tap(toggleButton);
      await tester.pump();

      // Sign Up fields should now be visible
      expect(find.text('DAFTAR AKUN eFOOTBALL'), findsOneWidget);
      expect(find.text('Username Manager'), findsOneWidget);
      expect(find.text('Ulangi / Konfirmasi Password'), findsOneWidget);
      expect(find.text('Gaya Main Favorit'), findsOneWidget);
    });

    testWidgets('Password obscure toggle works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Find password visibility button
      final visibilityIcons = find.byIcon(Icons.visibility_off);
      expect(visibilityIcons, findsOneWidget);

      // Tap visibility toggle
      await tester.tap(visibilityIcons);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
