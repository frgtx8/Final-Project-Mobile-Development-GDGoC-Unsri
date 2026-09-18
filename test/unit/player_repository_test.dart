import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/players/data/player_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerRepository Search & Filter Unit Tests', () {
    late PlayerRepository repository;

    setUp(() {
      repository = PlayerRepository();
    });

    test('Loads players and verifies non-empty catalog', () async {
      final players = await repository.loadPlayers();
      expect(players, isNotEmpty);
      expect(players.length, greaterThanOrEqualTo(10));
    });

    test('Searches players by query string', () async {
      await repository.loadPlayers();

      final messiResults = repository.searchPlayers(query: 'Messi');
      expect(messiResults, isNotEmpty);
      expect(messiResults.first.name, contains('Messi'));

      final madridResults = repository.searchPlayers(query: 'Chamartin');
      expect(madridResults, isNotEmpty);
    });

    test('Filters players by position (including multi-position support)', () async {
      await repository.loadPlayers();

      final gkList = repository.searchPlayers(position: 'GK');
      expect(gkList, isNotEmpty);
      for (final player in gkList) {
        expect(player.canPlayPosition('GK'), isTrue);
      }

      final dmfList = repository.searchPlayers(position: 'DMF');
      expect(dmfList, isNotEmpty);
      for (final player in dmfList) {
        expect(player.canPlayPosition('DMF'), isTrue);
      }
    });

    test('Filters players by player playstyle', () async {
      await repository.loadPlayers();

      final anchors = repository.searchPlayers(playstyle: 'Anchor Man');
      expect(anchors, isNotEmpty);
      for (final player in anchors) {
        expect(player.playerPlaystyle, equals('Anchor Man'));
      }
    });
  });
}
