import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/squad.dart';

class SquadRepository {
  static const String _localSquadsKey = 'local_saved_squads';

  static final _uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  Future<List<Squad>> getUserSquads(String userId) async {
    // 1. If Supabase is connected and userId is a valid UUID, fetch from cloud
    if (SupabaseService.isInitialized && _uuidRegex.hasMatch(userId)) {
      try {
        final client = SupabaseService.client;
        if (client != null) {
          final response = await client
              .from('squads')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);

          final List<dynamic> data = response as List<dynamic>;
          return data
              .map((e) => Squad.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {
        // Fall back to local
      }
    }

    // 2. Load from local SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonListStr = prefs.getStringList(_localSquadsKey) ?? [];
    return jsonListStr
        .map((str) => Squad.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .where((s) => s.userId == userId || userId == 'guest-user-id' || s.userId == 'guest-user-id')
        .toList();
  }

  Future<void> saveSquad(Squad squad) async {
    // 1. Save to Supabase if connected and userId is a valid UUID (logged in)
    if (SupabaseService.isInitialized &&
        _uuidRegex.hasMatch(squad.userId) &&
        _uuidRegex.hasMatch(squad.id)) {
      try {
        final client = SupabaseService.client;
        if (client != null) {
          await client.from('squads').upsert(squad.toJson());
        }
      } catch (_) {
        // Continue to save locally
      }
    }

    // 2. Save to local SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonListStr = prefs.getStringList(_localSquadsKey) ?? [];
    final existingSquads = jsonListStr
        .map((str) => Squad.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();

    existingSquads.removeWhere((s) => s.id == squad.id);
    existingSquads.insert(0, squad);

    await prefs.setStringList(
      _localSquadsKey,
      existingSquads.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<void> deleteSquad(String squadId) async {
    if (SupabaseService.isInitialized && _uuidRegex.hasMatch(squadId)) {
      try {
        final client = SupabaseService.client;
        if (client != null) {
          await client.from('squads').delete().eq('id', squadId);
        }
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonListStr = prefs.getStringList(_localSquadsKey) ?? [];
    final existingSquads = jsonListStr
        .map((str) => Squad.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();

    existingSquads.removeWhere((s) => s.id == squadId);

    await prefs.setStringList(
      _localSquadsKey,
      existingSquads.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<List<Squad>> getCommunitySquads() async {
    if (SupabaseService.isInitialized) {
      try {
        final client = SupabaseService.client;
        if (client != null) {
          final response = await client
              .from('squads')
              .select()
              .eq('is_public', true)
              .order('likes_count', ascending: false)
              .limit(20);

          final List<dynamic> data = response as List<dynamic>;
          if (data.isNotEmpty) {
            return data
                .map((e) => Squad.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }

    // Return sample community squads for demo/solo mode
    return _getSampleCommunitySquads();
  }

  List<Squad> _getSampleCommunitySquads() {
    return [
      Squad(
        id: 'sample-comm-1',
        userId: 'pro-user-1',
        squadName: 'Meta 4-2-1-3 Quick Counter',
        formation: '4-2-1-3',
        teamPlaystyle: 'Quick Counter',
        startingEleven: {
          'CF': 'p-001',
          'LWF': 'p-002',
          'RWF': 'p-003',
          'AMF': 'p-005',
          'DMF1': 'p-006',
          'DMF2': 'p-007',
          'LB': 'p-010',
          'CB1': 'p-008',
          'CB2': 'p-009',
          'RB': 'p-011',
          'GK': 'p-012',
        },
        teamStrength: 3120,
        isPublic: true,
        likesCount: 142,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Squad(
        id: 'sample-comm-2',
        userId: 'pro-user-2',
        squadName: 'Pep Tiki-Taka 4-3-3',
        formation: '4-3-3',
        teamPlaystyle: 'Possession Game',
        startingEleven: {
          'CF': 'p-001',
          'LWF': 'p-014',
          'RWF': 'p-013',
          'CMF1': 'p-004',
          'CMF2': 'p-007',
          'DMF': 'p-006',
          'LB': 'p-010',
          'CB1': 'p-008',
          'CB2': 'p-015',
          'RB': 'p-011',
          'GK': 'p-012',
        },
        teamStrength: 3095,
        isPublic: true,
        likesCount: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
