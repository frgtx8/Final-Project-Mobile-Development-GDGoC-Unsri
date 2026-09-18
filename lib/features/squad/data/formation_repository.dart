import '../../../core/constants/formations.dart';
import '../../../core/network/supabase_client.dart';

class FormationRepository {
  Future<List<String>> loadFormations() async {
    if (SupabaseService.isInitialized) {
      try {
        final client = SupabaseService.client;
        if (client != null) {
          final response = await client
              .from('formations')
              .select('id, name, slots')
              .order('id', ascending: true);

          final List<dynamic> list = response as List<dynamic>;
          for (final item in list) {
            final id = item['id'] as String;
            final slotsJson = item['slots'] as List<dynamic>?;
            if (slotsJson != null && slotsJson.isNotEmpty) {
              final slots = slotsJson
                  .map((s) => PitchSlot.fromJson(s as Map<String, dynamic>))
                  .toList();
              Formations.registerDynamicFormation(id, slots);
            }
          }
        }
      } catch (_) {
        // Fall back to built-in eFootball formations
      }
    }
    return Formations.allFormations;
  }

  Future<bool> addCustomFormation({
    required String id,
    required String name,
    required List<PitchSlot> slots,
  }) async {
    bool savedToCloud = false;
    if (SupabaseService.isInitialized) {
      final client = SupabaseService.client;
      if (client != null) {
        try {
          await client.from('formations').upsert({
            'id': id,
            'name': name,
            'slots': slots.map((s) => s.toJson()).toList(),
          });
          savedToCloud = true;
        } catch (_) {
          rethrow;
        }
      }
    }

    Formations.registerDynamicFormation(id, slots);
    return savedToCloud;
  }
}
