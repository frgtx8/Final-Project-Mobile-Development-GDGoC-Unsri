import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/players/domain/player.dart';
import 'package:efooty_tactics/features/ai_coach/data/gemini_ai_service.dart';

void main() {
  group('AI Doctor Tactical Rules & Out-of-Position Detection Tests', () {
    final aiService = GeminiAIService();

    final haaland = const Player(
      id: 'p-1',
      name: 'Erling Haaland',
      club: 'Manchester B',
      nationality: 'Norway',
      primaryPosition: 'CF',
      overallRating: 97,
      playerPlaystyle: 'Goal Poacher',
      keyStats: PlayerKeyStats(
        pace: 89,
        shooting: 96,
        passing: 68,
        dribbling: 82,
        defending: 45,
        physical: 92,
      ),
    );

    final rodri = const Player(
      id: 'p-2',
      name: 'Rodri',
      club: 'Manchester B',
      nationality: 'Spain',
      primaryPosition: 'DMF',
      overallRating: 95,
      playerPlaystyle: 'Anchor Man',
      keyStats: PlayerKeyStats(
        pace: 72,
        shooting: 76,
        passing: 93,
        dribbling: 84,
        defending: 95,
        physical: 90,
      ),
    );

    test('AI Doctor detects out-of-position blunder when striker is placed as defender', () async {
      // Lineup where Haaland (CF) is played as CB
      final blunderLineUp = {
        'CB1': haaland,
        'DMF1': rodri,
      };

      final report = await aiService.analyzeSquadSynergy(
        formation: '4-2-1-3',
        teamPlaystyle: 'Quick Counter',
        lineUpWithPositions: blunderLineUp,
      );

      // Score must be severely penalized
      expect(report.synergyScore, lessThan(65));
      expect(report.grade, anyOf('C', 'D', 'F'));

      // Weaknesses must explicitly report the blunder with the player name and out-of-position note
      final blunderWeakness = report.weaknesses.any((w) =>
          w.toLowerCase().contains('haaland') &&
          (w.toLowerCase().contains('bek') || w.toLowerCase().contains('cb')));
      expect(blunderWeakness, isTrue);

      // Alternatives must suggest proper center backs
      final hasAlternative = report.alternativeSuggestions.any((alt) =>
          alt.toLowerCase().contains('bek') ||
          alt.toLowerCase().contains('van dijk') ||
          alt.toLowerCase().contains('saliba') ||
          alt.toLowerCase().contains('cb'));
      expect(hasAlternative, isTrue);
    });

    test('AI Doctor gives high rating when players are placed in natural positions', () async {
      // Natural Lineup
      final naturalLineUp = {
        'CF': haaland,
        'DMF1': rodri,
      };

      final report = await aiService.analyzeSquadSynergy(
        formation: '4-2-1-3',
        teamPlaystyle: 'Quick Counter',
        lineUpWithPositions: naturalLineUp,
      );

      expect(report.synergyScore, greaterThanOrEqualTo(80));
      expect(report.grade, anyOf('S', 'A', 'B'));
    });
  });
}
