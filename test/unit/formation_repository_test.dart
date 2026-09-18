import 'package:flutter_test/flutter_test.dart';
import 'package:efooty_tactics/core/constants/formations.dart';
import 'package:efooty_tactics/features/squad/data/formation_repository.dart';

void main() {
  group('Formation & PitchSlot Unit Tests', () {
    test('Default formations list contains all 7 standard tactical meta setups', () {
      expect(Formations.allFormations, contains(Formations.f4213));
      expect(Formations.allFormations, contains(Formations.f433));
      expect(Formations.allFormations, contains(Formations.f4222));
      expect(Formations.allFormations, contains(Formations.f3223));
      expect(Formations.allFormations, contains(Formations.f4123));
      expect(Formations.allFormations, contains(Formations.f5212));
      expect(Formations.allFormations, contains(Formations.f343));
    });

    test('PitchSlot JSON serialization and deserialization preserves coordinates', () {
      const slot = PitchSlot(id: 'CF', defaultPosition: 'CF', x: 0.50, y: 0.18);
      final json = slot.toJson();
      expect(json['id'], 'CF');
      expect(json['defaultPosition'], 'CF');
      expect(json['x'], 0.50);
      expect(json['y'], 0.18);

      final decoded = PitchSlot.fromJson(json);
      expect(decoded.id, slot.id);
      expect(decoded.defaultPosition, slot.defaultPosition);
      expect(decoded.x, slot.x);
      expect(decoded.y, slot.y);
    });

    test('Dynamic formation registration makes custom formations immediately available', () {
      const customId = '4-3-1-2';
      const customSlots = [
        PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
        PitchSlot(id: 'LB', defaultPosition: 'LB', x: 0.15, y: 0.74),
        PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.38, y: 0.77),
        PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.62, y: 0.77),
        PitchSlot(id: 'RB', defaultPosition: 'RB', x: 0.85, y: 0.74),
        PitchSlot(id: 'DMF', defaultPosition: 'DMF', x: 0.50, y: 0.62),
        PitchSlot(id: 'CMF1', defaultPosition: 'CMF', x: 0.28, y: 0.52),
        PitchSlot(id: 'CMF2', defaultPosition: 'CMF', x: 0.72, y: 0.52),
        PitchSlot(id: 'AMF', defaultPosition: 'AMF', x: 0.50, y: 0.38),
        PitchSlot(id: 'CF1', defaultPosition: 'CF', x: 0.38, y: 0.18),
        PitchSlot(id: 'CF2', defaultPosition: 'CF', x: 0.62, y: 0.18),
      ];

      Formations.registerDynamicFormation(customId, customSlots);
      expect(Formations.allFormations, contains(customId));
      expect(Formations.getSlots(customId), hasLength(11));
    });

    test('FormationRepository loads formations without crashing', () async {
      final repo = FormationRepository();
      final formations = await repo.loadFormations();
      expect(formations, isNotEmpty);
      expect(formations, contains('4-2-1-3'));
    });
  });
}
