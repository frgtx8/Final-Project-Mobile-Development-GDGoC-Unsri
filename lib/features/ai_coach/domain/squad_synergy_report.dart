import 'package:flutter/foundation.dart';

@immutable
class SquadSynergyReport {
  final int synergyScore; // 0 - 100
  final String grade; // 'S', 'A', 'B', 'C'
  final String tacticalVerdict;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> tacticalInstructions;
  final List<String> alternativeSuggestions;

  const SquadSynergyReport({
    required this.synergyScore,
    required this.grade,
    required this.tacticalVerdict,
    required this.strengths,
    required this.weaknesses,
    required this.tacticalInstructions,
    required this.alternativeSuggestions,
  });

  factory SquadSynergyReport.fromJson(Map<String, dynamic> json) {
    final score = (json['synergy_score'] as num?)?.toInt() ?? 75;
    String grade = json['grade'] as String? ?? '';
    if (grade.isEmpty) {
      if (score >= 90) {
        grade = 'S';
      } else if (score >= 80) {
        grade = 'A';
      } else if (score >= 65) {
        grade = 'B';
      } else {
        grade = 'C';
      }
    }

    return SquadSynergyReport(
      synergyScore: score,
      grade: grade,
      tacticalVerdict: json['tactical_verdict'] as String? ??
          'Skuad memiliki potensi serangan yang kuat namun perlu penyesuaian stabilitas pertahanan.',
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tacticalInstructions: (json['tactical_instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      alternativeSuggestions:
          (json['alternative_suggestions'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'synergy_score': synergyScore,
        'grade': grade,
        'tactical_verdict': tacticalVerdict,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'tactical_instructions': tacticalInstructions,
        'alternative_suggestions': alternativeSuggestions,
      };
}
