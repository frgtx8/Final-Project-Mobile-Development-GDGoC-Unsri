import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/ai_coach/data/gemini_ai_service.dart';
import 'package:efooty_tactics/features/players/domain/player.dart';

void main() {
  group('AI Scout Advice & eFootball Playstyle Matching Tests', () {
    late GeminiAIService aiService;

    const mockCatalog = [
      Player(
        id: 'p-1',
        name: 'Jude Bellingham',
        club: 'Real Madrid',
        nationality: 'England',
        primaryPosition: 'AMF',
        overallRating: 97,
        playerPlaystyle: 'Hole Player',
        keyStats: PlayerKeyStats(
            pace: 84, shooting: 88, passing: 89, dribbling: 91, defending: 79, physical: 88),
      ),
      Player(
        id: 'p-2',
        name: 'Florian Wirtz',
        club: 'Bayer Leverkusen',
        nationality: 'Germany',
        primaryPosition: 'AMF',
        overallRating: 95,
        playerPlaystyle: 'Hole Player',
        keyStats: PlayerKeyStats(
            pace: 86, shooting: 86, passing: 92, dribbling: 94, defending: 54, physical: 72),
      ),
      Player(
        id: 'p-3',
        name: 'Erling Haaland',
        club: 'Manchester City',
        nationality: 'Norway',
        primaryPosition: 'CF',
        overallRating: 97,
        playerPlaystyle: 'Goal Poacher',
        keyStats: PlayerKeyStats(
            pace: 91, shooting: 95, passing: 70, dribbling: 78, defending: 45, physical: 94),
      ),
      Player(
        id: 'p-4',
        name: 'Rodri',
        club: 'Manchester City',
        nationality: 'Spain',
        primaryPosition: 'DMF',
        overallRating: 98,
        playerPlaystyle: 'Anchor Man',
        keyStats: PlayerKeyStats(
            pace: 68, shooting: 78, passing: 93, dribbling: 84, defending: 95, physical: 90),
      ),
    ];

    setUp(() {
      aiService = GeminiAIService();
    });

    test('Query for Pemburu Celah returns Hole Players and NOT Anchor Man or Build Up', () async {
      final response = await aiService.askPlayerScoutAdvice(
        query: '3 pemain pemburu celah terbaik saat ini?',
        currentPlaystyle: 'Quick Counter',
        catalog: mockCatalog,
      );

      // Must contain Hole Player references
      expect(response.toLowerCase(), contains('pemburu celah'));
      expect(response, contains('Jude Bellingham'));
      expect(response, contains('Florian Wirtz'));

      // MUST NOT recommend Rodri as Hole Player
      expect(response.contains('Rodri (Manchester B) - DMF (Anchor Man)'), isFalse);
    });

    test('Query for Pemburu Gol returns Goal Poachers', () async {
      final response = await aiService.askPlayerScoutAdvice(
        query: 'rekomendasi striker pemburu gol',
        currentPlaystyle: 'Long Ball Counter',
        catalog: mockCatalog,
      );

      expect(response.toLowerCase(), contains('pemburu gol'));
      expect(response, contains('Erling Haaland'));
    });

    test('Query for Gelandang Jangkar returns Anchor Man', () async {
      final response = await aiService.askPlayerScoutAdvice(
        query: 'cari gelandang jangkar dmf penyeimbang',
        currentPlaystyle: 'Quick Counter',
        catalog: mockCatalog,
      );

      expect(response.toLowerCase(), contains('jangkar'));
      expect(response, contains('Rodri'));
    });
  });
}
