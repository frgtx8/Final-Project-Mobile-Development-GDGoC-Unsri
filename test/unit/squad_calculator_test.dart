import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/players/domain/player.dart';
import 'package:efooty_tactics/features/squad/domain/squad.dart';

void main() {
  group('Squad & Team Strength Unit Tests', () {
    final mockPlayers = {
      'p-1': const Player(
        id: 'p-1',
        name: 'Player 1',
        club: 'Club A',
        nationality: 'ID',
        primaryPosition: 'CF',
        overallRating: 90,
        playerPlaystyle: 'Goal Poacher',
        keyStats: PlayerKeyStats(
            pace: 90,
            shooting: 90,
            passing: 80,
            dribbling: 85,
            defending: 50,
            physical: 80),
      ),
      'p-2': const Player(
        id: 'p-2',
        name: 'Player 2',
        club: 'Club B',
        nationality: 'ID',
        primaryPosition: 'DMF',
        overallRating: 88,
        playerPlaystyle: 'Anchor Man',
        keyStats: PlayerKeyStats(
            pace: 75,
            shooting: 70,
            passing: 85,
            dribbling: 80,
            defending: 92,
            physical: 90),
      ),
    };

    test('calculateTeamStrength returns 0 when starting eleven is empty', () {
      final ts = Squad.calculateTeamStrength({}, mockPlayers);
      expect(ts, equals(0));
    });

    test('calculateTeamStrength correctly calculates partial squad', () {
      final startingXI = {'CF': 'p-1', 'DMF': 'p-2'};
      final ts = Squad.calculateTeamStrength(startingXI, mockPlayers);

      // Average = (90 + 88) / 2 = 89. (89 * 11).round() = 979
      expect(ts, equals(979));
    });

    test('calculateTeamStrength adds synergy bonus when squad has 11 players', () {
      final elevenMap = <String, String>{};
      for (int i = 1; i <= 11; i++) {
        elevenMap['pos-$i'] = 'p-1';
      }

      final ts = Squad.calculateTeamStrength(elevenMap, mockPlayers);
      // Rating 90 * 11 = 990 + 50 bonus = 1040
      expect(ts, equals(1040));
    });

    test('Player effective rating drops when placed out of position', () {
      final striker = mockPlayers['p-1']!;
      expect(striker.primaryPosition, equals('CF'));
      expect(striker.overallRating, equals(90));

      // Same position: 100%
      expect(striker.getEffectiveRating('CF'), equals(90));

      // Striker placed as Defender (CB): drops to ~70%
      final cbRating = striker.getEffectiveRating('CB');
      expect(cbRating, equals((90 * 0.70).round())); // 63
      expect(cbRating, lessThan(90));

      // Striker placed as GK: drops to ~45%
      final gkRating = striker.getEffectiveRating('GK');
      expect(gkRating, equals((90 * 0.45).round())); // 41
      expect(gkRating, lessThan(cbRating));
    });

    test('calculateTeamStrength drops when striker is placed as defender', () {
      // Natural positions: CF at CF, DMF at DMF
      final naturalXI = {'CF': 'p-1', 'DMF': 'p-2'};
      final naturalTS = Squad.calculateTeamStrength(naturalXI, mockPlayers);

      // Blunder: CF (p-1) placed as CB
      final blunderXI = {'CB': 'p-1', 'DMF': 'p-2'};
      final blunderTS = Squad.calculateTeamStrength(blunderXI, mockPlayers);

      expect(blunderTS, lessThan(naturalTS));
    });

    test('Squad domain model serialization to and from JSON', () {
      final squad = Squad(
        id: 'sq-123',
        userId: 'user-456',
        squadName: 'Garuda Muda',
        formation: '4-2-1-3',
        teamPlaystyle: 'Quick Counter',
        startingEleven: {'CF': 'p-1'},
        teamStrength: 1040,
        isPublic: true,
        likesCount: 15,
        createdAt: DateTime.parse('2026-09-13T10:00:00Z'),
      );

      final json = squad.toJson();
      expect(json['id'], equals('sq-123'));
      expect(json['squad_name'], equals('Garuda Muda'));
      expect(json['is_public'], isTrue);

      final deserialized = Squad.fromJson(json);
      expect(deserialized.id, equals(squad.id));
      expect(deserialized.squadName, equals(squad.squadName));
      expect(deserialized.teamStrength, equals(1040));
      expect(deserialized.likesCount, equals(15));
    });
  });
}
