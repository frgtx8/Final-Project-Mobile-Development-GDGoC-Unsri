import 'package:flutter/foundation.dart';

@immutable
class PlayerKeyStats {
  final int pace;
  final int shooting;
  final int passing;
  final int dribbling;
  final int defending;
  final int physical;

  const PlayerKeyStats({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,
  });

  factory PlayerKeyStats.fromJson(Map<String, dynamic> json) {
    return PlayerKeyStats(
      pace: (json['pace'] as num?)?.toInt() ?? 60,
      shooting: (json['shooting'] as num?)?.toInt() ?? 60,
      passing: (json['passing'] as num?)?.toInt() ?? 60,
      dribbling: (json['dribbling'] as num?)?.toInt() ?? 60,
      defending: (json['defending'] as num?)?.toInt() ?? 60,
      physical: (json['physical'] as num?)?.toInt() ?? 60,
    );
  }

  Map<String, dynamic> toJson() => {
        'pace': pace,
        'shooting': shooting,
        'passing': passing,
        'dribbling': dribbling,
        'defending': defending,
        'physical': physical,
      };
}

@immutable
class Player {
  final String id;
  final String name;
  final String club;
  final String nationality;
  final String primaryPosition;
  final List<String> secondaryPositions;
  final int overallRating;
  final String playerPlaystyle;
  final String? imageUrl;
  final PlayerKeyStats keyStats;
  final List<String> skills;

  const Player({
    required this.id,
    required this.name,
    required this.club,
    required this.nationality,
    required this.primaryPosition,
    this.secondaryPositions = const [],
    required this.overallRating,
    required this.playerPlaystyle,
    this.imageUrl,
    required this.keyStats,
    this.skills = const [],
  });

  bool canPlayPosition(String position) {
    final normalized = position.replaceAll(RegExp(r'[0-9]'), '');
    return primaryPosition == normalized || secondaryPositions.contains(normalized);
  }

  /// Menghitung penurunan OVR jika pemain dipasang di luar posisi alaminya (eFootball realism)
  int getEffectiveRating(String slotPosition) {
    final normalizedSlot = slotPosition.replaceAll(RegExp(r'[0-9]'), '');

    // 1. Posisi Primer: 100% OVR
    if (primaryPosition == normalizedSlot) {
      return overallRating;
    }

    // 2. Posisi Sekunder (posisi yang bisa dimainkan): 100% OVR
    if (secondaryPositions.contains(normalizedSlot)) {
      return overallRating;
    }

    // 3. Penalti Ekstrem: Pemain biasa dijadikan Kiper
    if (normalizedSlot == 'GK' && primaryPosition != 'GK') {
      return (overallRating * 0.45).round();
    }
    // Kiper dijadikan pemain lapangan
    if (primaryPosition == 'GK' && normalizedSlot != 'GK') {
      return (overallRating * 0.40).round();
    }

    const forwards = ['CF', 'SS', 'LWF', 'RWF'];
    const midfielders = ['AMF', 'CMF', 'DMF', 'LMF', 'RMF'];
    const defenders = ['CB', 'LB', 'RB', 'LWB', 'RWB'];

    final isPlayerFwd = forwards.contains(primaryPosition);
    final isPlayerMid = midfielders.contains(primaryPosition);
    final isPlayerDef = defenders.contains(primaryPosition);

    final isSlotFwd = forwards.contains(normalizedSlot);
    final isSlotMid = midfielders.contains(normalizedSlot);
    final isSlotDef = defenders.contains(normalizedSlot);

    // Penyerang dijadikan Bek atau Bek dijadikan Penyerang (Penalti -30%)
    if ((isPlayerFwd && isSlotDef) || (isPlayerDef && isSlotFwd)) {
      return (overallRating * 0.70).round();
    }

    // Gelandang dijadikan Bek atau Bek dijadikan Gelandang (Penalti -18%)
    if ((isPlayerMid && isSlotDef) || (isPlayerDef && isSlotMid)) {
      return (overallRating * 0.82).round();
    }

    // Penyerang dijadikan Gelandang atau sebaliknya (Penalti -15%)
    if ((isPlayerFwd && isSlotMid) || (isPlayerMid && isSlotFwd)) {
      return (overallRating * 0.85).round();
    }

    // Penalti umum posisi asing (-22%)
    return (overallRating * 0.78).round();
  }

  List<String> get allPlayablePositions => [primaryPosition, ...secondaryPositions];

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      club: json['club'] as String? ?? 'Free Agent',
      nationality: json['nationality'] as String? ?? 'Unknown',
      primaryPosition: json['primary_position'] as String,
      secondaryPositions: (json['secondary_positions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      overallRating: (json['overall_rating'] as num).toInt(),
      playerPlaystyle: json['player_playstyle'] as String,
      imageUrl: json['image_url'] as String?,
      keyStats: PlayerKeyStats.fromJson(
        json['key_stats'] as Map<String, dynamic>? ?? {},
      ),
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'club': club,
        'nationality': nationality,
        'primary_position': primaryPosition,
        'secondary_positions': secondaryPositions,
        'overall_rating': overallRating,
        'player_playstyle': playerPlaystyle,
        'image_url': imageUrl,
        'key_stats': keyStats.toJson(),
        'skills': skills,
      };

  Player copyWith({
    String? id,
    String? name,
    String? club,
    String? nationality,
    String? primaryPosition,
    List<String>? secondaryPositions,
    int? overallRating,
    String? playerPlaystyle,
    String? imageUrl,
    PlayerKeyStats? keyStats,
    List<String>? skills,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      club: club ?? this.club,
      nationality: nationality ?? this.nationality,
      primaryPosition: primaryPosition ?? this.primaryPosition,
      secondaryPositions: secondaryPositions ?? this.secondaryPositions,
      overallRating: overallRating ?? this.overallRating,
      playerPlaystyle: playerPlaystyle ?? this.playerPlaystyle,
      imageUrl: imageUrl ?? this.imageUrl,
      keyStats: keyStats ?? this.keyStats,
      skills: skills ?? this.skills,
    );
  }
}
