import 'package:flutter/foundation.dart';
import '../../players/domain/player.dart';

@immutable
class Squad {
  final String id;
  final String userId;
  final String squadName;
  final String formation;
  final String teamPlaystyle;
  final Map<String, String> startingEleven; // Map<SlotId, PlayerId>
  final int teamStrength;
  final bool isPublic;
  final int likesCount;
  final DateTime createdAt;

  const Squad({
    required this.id,
    required this.userId,
    required this.squadName,
    required this.formation,
    required this.teamPlaystyle,
    required this.startingEleven,
    required this.teamStrength,
    this.isPublic = false,
    this.likesCount = 0,
    required this.createdAt,
  });

  static const _knownPositions = {
    'GK', 'CB', 'LB', 'RB', 'LWB', 'RWB',
    'DMF', 'CMF', 'AMF', 'LMF', 'RMF',
    'LWF', 'RWF', 'SS', 'CF',
  };

  static int calculateTeamStrength(
    Map<String, String> startingEleven,
    Map<String, Player> playersById, {
    Map<String, String>? slotPositions,
  }) {
    if (startingEleven.isEmpty) return 0;
    int totalRating = 0;
    int count = 0;

    for (final entry in startingEleven.entries) {
      final slotId = entry.key;
      final playerId = entry.value;
      final player = playersById[playerId];
      if (player != null) {
        final rawPos = slotPositions?[slotId] ??
            slotId.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
        final slotPos =
            _knownPositions.contains(rawPos) ? rawPos : player.primaryPosition;
        final effectiveRating = player.getEffectiveRating(slotPos);
        totalRating += effectiveRating;
        count++;
      }
    }

    if (count == 0) return 0;
    // eFootball style Team Strength = sum of effective ratings + synergy bonus
    final average = totalRating / count;
    return (average * 11).round() + (count >= 11 ? 50 : 0);
  }

  factory Squad.fromJson(Map<String, dynamic> json) {
    return Squad(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? 'guest-user-id',
      squadName: json['squad_name'] as String? ?? 'My Dream Squad',
      formation: json['formation'] as String? ?? '4-2-1-3',
      teamPlaystyle: json['team_playstyle'] as String? ?? 'Quick Counter',
      startingEleven: Map<String, String>.from(
        json['starting_eleven'] as Map<String, dynamic>? ?? {},
      ),
      teamStrength: (json['team_strength'] as num?)?.toInt() ?? 0,
      isPublic: json['is_public'] as bool? ?? false,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'squad_name': squadName,
        'formation': formation,
        'team_playstyle': teamPlaystyle,
        'starting_eleven': startingEleven,
        'team_strength': teamStrength,
        'is_public': isPublic,
        'likes_count': likesCount,
        'created_at': createdAt.toIso8601String(),
      };

  Squad copyWith({
    String? id,
    String? userId,
    String? squadName,
    String? formation,
    String? teamPlaystyle,
    Map<String, String>? startingEleven,
    int? teamStrength,
    bool? isPublic,
    int? likesCount,
    DateTime? createdAt,
  }) {
    return Squad(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      squadName: squadName ?? this.squadName,
      formation: formation ?? this.formation,
      teamPlaystyle: teamPlaystyle ?? this.teamPlaystyle,
      startingEleven: startingEleven ?? this.startingEleven,
      teamStrength: teamStrength ?? this.teamStrength,
      isPublic: isPublic ?? this.isPublic,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
