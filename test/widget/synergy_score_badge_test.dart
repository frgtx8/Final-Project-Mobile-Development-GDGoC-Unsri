import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/ai_coach/presentation/synergy_score_badge.dart';

void main() {
  group('SynergyScoreBadge Widget Tests', () {
    testWidgets('Renders Grade S and score 95 properly in full mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SynergyScoreBadge(score: 95, grade: 'S'),
            ),
          ),
        ),
      );

      expect(find.text('S'), findsOneWidget);
      expect(find.text('95/100'), findsOneWidget);
    });

    testWidgets('Renders Grade B properly in compact mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SynergyScoreBadge(score: 72, grade: 'B', isCompact: true),
            ),
          ),
        ),
      );

      expect(find.text('Grade B'), findsOneWidget);
      expect(find.text('(72)'), findsOneWidget);
    });
  });
}
