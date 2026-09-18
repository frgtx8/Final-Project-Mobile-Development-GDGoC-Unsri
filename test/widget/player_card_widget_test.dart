import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/players/domain/player.dart';
import 'package:efooty_tactics/features/players/presentation/player_card_widget.dart';

void main() {
  group('PlayerCardWidget Tests', () {
    const testPlayer = Player(
      id: 'p-test',
      name: 'Erling Haaland',
      club: 'Manchester B',
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
        physical: 94,
      ),
      skills: ['First-time Shot', 'Heading'],
    );

    testWidgets('Renders all player information in full card mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerCardWidget(player: testPlayer),
          ),
        ),
      );

      expect(find.text('Erling Haaland'), findsOneWidget);
      expect(find.text('97'), findsOneWidget);
      expect(find.text('CF'), findsOneWidget);
      expect(find.text('Goal Poacher'), findsOneWidget);
      expect(find.textContaining('Manchester B'), findsOneWidget);

      // Key stats
      expect(find.text('PAC'), findsOneWidget);
      expect(find.text('91'), findsOneWidget);
      expect(find.text('SHO'), findsOneWidget);
      expect(find.text('95'), findsOneWidget);
    });

    testWidgets('Renders player card in compact mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerCardWidget(player: testPlayer, isCompact: true),
          ),
        ),
      );

      expect(find.text('Erling Haaland'), findsOneWidget);
      expect(find.text('97'), findsOneWidget);
      expect(find.text('CF'), findsOneWidget);
    });

    testWidgets('Renders assigned slot badge when player is in another slot',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerCardWidget(
              player: testPlayer,
              isCompact: true,
              assignedSlot: 'CB1',
            ),
          ),
        ),
      );

      expect(find.text('Terpakai di: CB1'), findsOneWidget);
    });

    testWidgets('Renders active current slot badge when isCurrentSlot is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerCardWidget(
              player: testPlayer,
              isCompact: true,
              isCurrentSlot: true,
            ),
          ),
        ),
      );

      expect(find.text('Terpasang di sini'), findsOneWidget);
    });

    testWidgets('Renders versatile badge and secondary positions',
        (WidgetTester tester) async {
      const versatilePlayer = Player(
        id: 'p-versatile',
        name: 'Kylian Mbappé',
        club: 'Real Madrid',
        nationality: 'France',
        primaryPosition: 'CF',
        secondaryPositions: ['LWF', 'SS'],
        overallRating: 96,
        playerPlaystyle: 'Goal Poacher',
        keyStats: PlayerKeyStats(
          pace: 97,
          shooting: 92,
          passing: 80,
          dribbling: 93,
          defending: 39,
          physical: 78,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlayerCardWidget(player: versatilePlayer, isCompact: true),
          ),
        ),
      );

      expect(find.text('Versatile'), findsOneWidget);
      expect(find.textContaining('Alt: LWF, SS'), findsOneWidget);
    });
  });
}
