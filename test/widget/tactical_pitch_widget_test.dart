import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/players/domain/player.dart';
import 'package:efooty_tactics/features/squad/presentation/tactical_pitch_widget.dart';

void main() {
  group('TacticalPitchWidget Tests', () {
    const player1 = Player(
      id: 'p-cf',
      name: 'Haaland',
      club: 'City',
      nationality: 'Norway',
      primaryPosition: 'CF',
      overallRating: 97,
      playerPlaystyle: 'Goal Poacher',
      keyStats: PlayerKeyStats(
          pace: 91,
          shooting: 95,
          passing: 70,
          dribbling: 78,
          defending: 45,
          physical: 94),
    );

    testWidgets('Renders pitch and correctly displays assigned player name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: TacticalPitchWidget(
                formation: '4-2-1-3',
                startingEleven: const {'CF': 'p-cf'},
                playersById: const {'p-cf': player1},
                onPlayerAssigned: (_, __) {},
              ),
            ),
          ),
        ),
      );

      // Verify the CF player name is displayed
      expect(find.text('Haaland'), findsOneWidget);
      // Verify other empty slots show their slot ID (e.g. GK, LB, RB)
      expect(find.text('GK'), findsWidgets);
      expect(find.text('LB'), findsWidgets);
    });
  });
}
