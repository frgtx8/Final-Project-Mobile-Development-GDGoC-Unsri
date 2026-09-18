import 'package:flutter/foundation.dart';

@immutable
class PitchSlot {
  final String id;
  final String defaultPosition;
  final double x; // 0.0 (left) to 1.0 (right)
  final double y; // 0.0 (top/attack) to 1.0 (bottom/GK)

  const PitchSlot({
    required this.id,
    required this.defaultPosition,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'defaultPosition': defaultPosition,
        'x': x,
        'y': y,
      };

  factory PitchSlot.fromJson(Map<String, dynamic> json) => PitchSlot(
        id: json['id'] as String,
        defaultPosition: json['defaultPosition'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}

class Formations {
  static const String f4213 = '4-2-1-3';
  static const String f433 = '4-3-3';
  static const String f4222 = '4-2-2-2';
  static const String f3223 = '3-2-2-3';
  static const String f4123 = '4-1-2-3';
  static const String f5212 = '5-2-1-2';
  static const String f343 = '3-4-3';

  static const List<String> defaultFormations = [
    f4213,
    f433,
    f4222,
    f3223,
    f4123,
    f5212,
    f343,
  ];

  static final Map<String, List<PitchSlot>> _dynamicFormations = {};

  static void registerDynamicFormation(String id, List<PitchSlot> slots) {
    _dynamicFormations[id] = slots;
  }

  static List<String> get allFormations {
    final list = [...defaultFormations];
    for (final key in _dynamicFormations.keys) {
      if (!list.contains(key)) {
        list.add(key);
      }
    }
    return list;
  }

  static List<PitchSlot> getSlots(String formation) {
    if (_dynamicFormations.containsKey(formation)) {
      return _dynamicFormations[formation]!;
    }
    switch (formation) {
      case f4213:
        return const [
          PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
          PitchSlot(id: 'LB', defaultPosition: 'LB', x: 0.15, y: 0.74),
          PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.38, y: 0.77),
          PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.62, y: 0.77),
          PitchSlot(id: 'RB', defaultPosition: 'RB', x: 0.85, y: 0.74),
          PitchSlot(id: 'DMF1', defaultPosition: 'DMF', x: 0.35, y: 0.58),
          PitchSlot(id: 'DMF2', defaultPosition: 'CMF', x: 0.65, y: 0.58),
          PitchSlot(id: 'AMF', defaultPosition: 'AMF', x: 0.50, y: 0.42),
          PitchSlot(id: 'LWF', defaultPosition: 'LWF', x: 0.18, y: 0.24),
          PitchSlot(id: 'CF', defaultPosition: 'CF', x: 0.50, y: 0.18),
          PitchSlot(id: 'RWF', defaultPosition: 'RWF', x: 0.82, y: 0.24),
        ];

      case f433:
        return const [
          PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
          PitchSlot(id: 'LB', defaultPosition: 'LB', x: 0.15, y: 0.74),
          PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.38, y: 0.77),
          PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.62, y: 0.77),
          PitchSlot(id: 'RB', defaultPosition: 'RB', x: 0.85, y: 0.74),
          PitchSlot(id: 'DMF', defaultPosition: 'DMF', x: 0.50, y: 0.60),
          PitchSlot(id: 'CMF1', defaultPosition: 'CMF', x: 0.30, y: 0.46),
          PitchSlot(id: 'CMF2', defaultPosition: 'CMF', x: 0.70, y: 0.46),
          PitchSlot(id: 'LWF', defaultPosition: 'LWF', x: 0.18, y: 0.22),
          PitchSlot(id: 'CF', defaultPosition: 'CF', x: 0.50, y: 0.18),
          PitchSlot(id: 'RWF', defaultPosition: 'RWF', x: 0.82, y: 0.22),
        ];

      case f4222:
        return const [
          PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
          PitchSlot(id: 'LB', defaultPosition: 'LB', x: 0.15, y: 0.74),
          PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.38, y: 0.77),
          PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.62, y: 0.77),
          PitchSlot(id: 'RB', defaultPosition: 'RB', x: 0.85, y: 0.74),
          PitchSlot(id: 'DMF1', defaultPosition: 'DMF', x: 0.35, y: 0.60),
          PitchSlot(id: 'DMF2', defaultPosition: 'CMF', x: 0.65, y: 0.60),
          PitchSlot(id: 'AMF1', defaultPosition: 'AMF', x: 0.25, y: 0.38),
          PitchSlot(id: 'AMF2', defaultPosition: 'AMF', x: 0.75, y: 0.38),
          PitchSlot(id: 'CF1', defaultPosition: 'CF', x: 0.38, y: 0.18),
          PitchSlot(id: 'CF2', defaultPosition: 'CF', x: 0.62, y: 0.18),
        ];

      case f3223:
        return const [
          PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
          PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.25, y: 0.76),
          PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.50, y: 0.78),
          PitchSlot(id: 'CB3', defaultPosition: 'CB', x: 0.75, y: 0.76),
          PitchSlot(id: 'DMF1', defaultPosition: 'DMF', x: 0.35, y: 0.60),
          PitchSlot(id: 'DMF2', defaultPosition: 'CMF', x: 0.65, y: 0.60),
          PitchSlot(id: 'AMF1', defaultPosition: 'AMF', x: 0.30, y: 0.40),
          PitchSlot(id: 'AMF2', defaultPosition: 'AMF', x: 0.70, y: 0.40),
          PitchSlot(id: 'LWF', defaultPosition: 'LWF', x: 0.18, y: 0.22),
          PitchSlot(id: 'CF', defaultPosition: 'CF', x: 0.50, y: 0.18),
          PitchSlot(id: 'RWF', defaultPosition: 'RWF', x: 0.82, y: 0.22),
        ];

      case f5212:
        return const [
          PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
          PitchSlot(id: 'LWB', defaultPosition: 'LB', x: 0.12, y: 0.68),
          PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.30, y: 0.78),
          PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.50, y: 0.80),
          PitchSlot(id: 'CB3', defaultPosition: 'CB', x: 0.70, y: 0.78),
          PitchSlot(id: 'RWB', defaultPosition: 'RB', x: 0.88, y: 0.68),
          PitchSlot(id: 'DMF', defaultPosition: 'DMF', x: 0.38, y: 0.56),
          PitchSlot(id: 'CMF', defaultPosition: 'CMF', x: 0.62, y: 0.56),
          PitchSlot(id: 'AMF', defaultPosition: 'AMF', x: 0.50, y: 0.38),
          PitchSlot(id: 'CF1', defaultPosition: 'CF', x: 0.38, y: 0.18),
          PitchSlot(id: 'CF2', defaultPosition: 'CF', x: 0.62, y: 0.18),
        ];

      case f343:
        return const [
          PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
          PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.25, y: 0.78),
          PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.50, y: 0.80),
          PitchSlot(id: 'CB3', defaultPosition: 'CB', x: 0.75, y: 0.78),
          PitchSlot(id: 'LMF', defaultPosition: 'LMF', x: 0.15, y: 0.52),
          PitchSlot(id: 'CMF1', defaultPosition: 'CMF', x: 0.38, y: 0.54),
          PitchSlot(id: 'CMF2', defaultPosition: 'CMF', x: 0.62, y: 0.54),
          PitchSlot(id: 'RMF', defaultPosition: 'RMF', x: 0.85, y: 0.52),
          PitchSlot(id: 'LWF', defaultPosition: 'LWF', x: 0.20, y: 0.24),
          PitchSlot(id: 'CF', defaultPosition: 'CF', x: 0.50, y: 0.18),
          PitchSlot(id: 'RWF', defaultPosition: 'RWF', x: 0.80, y: 0.24),
        ];

      case f4123:
      default:
        return const [
          PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
          PitchSlot(id: 'LB', defaultPosition: 'LB', x: 0.15, y: 0.74),
          PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.38, y: 0.77),
          PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.62, y: 0.77),
          PitchSlot(id: 'RB', defaultPosition: 'RB', x: 0.85, y: 0.74),
          PitchSlot(id: 'DMF', defaultPosition: 'DMF', x: 0.50, y: 0.60),
          PitchSlot(id: 'AMF1', defaultPosition: 'AMF', x: 0.32, y: 0.42),
          PitchSlot(id: 'AMF2', defaultPosition: 'AMF', x: 0.68, y: 0.42),
          PitchSlot(id: 'LWF', defaultPosition: 'LWF', x: 0.18, y: 0.22),
          PitchSlot(id: 'CF', defaultPosition: 'CF', x: 0.50, y: 0.18),
          PitchSlot(id: 'RWF', defaultPosition: 'RWF', x: 0.82, y: 0.22),
        ];
    }
  }
}
