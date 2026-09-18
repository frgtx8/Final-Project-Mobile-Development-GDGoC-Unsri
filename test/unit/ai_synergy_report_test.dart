import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/features/ai_coach/domain/squad_synergy_report.dart';

void main() {
  group('SquadSynergyReport Unit Tests', () {
    test('Correctly parses full JSON from Gemini AI', () {
      final json = {
        'synergy_score': 92,
        'grade': 'S',
        'tactical_verdict':
            'Susunan pemain sangat seimbang dengan transisi cepat.',
        'strengths': [
          'Anchor Man menstabilkan pertahanan',
          'Penyelesaian CF sangat klinis'
        ],
        'weaknesses': ['Kekurangan pelapis untuk bek sayap'],
        'tactical_instructions': ['Pasang Deep Line pada DMF'],
        'alternative_suggestions': ['Gunakan Saliba sebagai bek cadangan'],
      };

      final report = SquadSynergyReport.fromJson(json);

      expect(report.synergyScore, equals(92));
      expect(report.grade, equals('S'));
      expect(report.strengths.length, equals(2));
      expect(report.weaknesses.length, equals(1));
      expect(report.tacticalInstructions.first,
          equals('Pasang Deep Line pada DMF'));
      expect(report.alternativeSuggestions.first,
          equals('Gunakan Saliba sebagai bek cadangan'));
    });

    test('Infers grade automatically if not explicitly provided in JSON', () {
      final jsonS = {
        'synergy_score': 95,
        'tactical_verdict': 'Superb',
      };
      expect(SquadSynergyReport.fromJson(jsonS).grade, equals('S'));

      final jsonA = {
        'synergy_score': 84,
        'tactical_verdict': 'Great',
      };
      expect(SquadSynergyReport.fromJson(jsonA).grade, equals('A'));

      final jsonB = {
        'synergy_score': 70,
        'tactical_verdict': 'Good',
      };
      expect(SquadSynergyReport.fromJson(jsonB).grade, equals('B'));

      final jsonC = {
        'synergy_score': 55,
        'tactical_verdict': 'Needs work',
      };
      expect(SquadSynergyReport.fromJson(jsonC).grade, equals('C'));
    });

    test('Serializes to JSON accurately', () {
      const report = SquadSynergyReport(
        synergyScore: 88,
        grade: 'A',
        tacticalVerdict: 'Solid team',
        strengths: ['Great passing'],
        weaknesses: ['Slow pace'],
        tacticalInstructions: ['Stay back'],
        alternativeSuggestions: ['Faster CB'],
      );

      final map = report.toJson();
      expect(map['synergy_score'], equals(88));
      expect(map['grade'], equals('A'));
      expect(map['strengths'], contains('Great passing'));
    });
  });
}
