import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/player.dart';

class PlayerRepository {
  List<Player> _cachedPlayers = [];

  List<Player> get cachedPlayers => List.unmodifiable(_cachedPlayers);

  Future<List<Player>> loadPlayers({bool forceRefresh = false}) async {
    if (_cachedPlayers.isNotEmpty && !forceRefresh) {
      return _cachedPlayers;
    }

    // Preload secondary positions map from assets as fallback
    Map<String, List<String>> fallbackSecMap = {};
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/default_players.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      for (final item in jsonList) {
        final id = item['id'] as String?;
        final secs = (item['secondary_positions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
        if (id != null && secs != null && secs.isNotEmpty) {
          fallbackSecMap[id] = secs;
        }
      }
    } catch (_) {}

    // 1. Try fetching from Supabase if connected
    if (SupabaseService.isInitialized) {
      try {
        final client = SupabaseService.client;
        if (client != null) {
          final response = await client
              .from('players')
              .select()
              .order('overall_rating', ascending: false);

          final List<dynamic> data = response as List<dynamic>;
          if (data.isNotEmpty) {
            _cachedPlayers = data.map((e) {
              final p = Player.fromJson(e as Map<String, dynamic>);
              if (p.secondaryPositions.isEmpty &&
                  fallbackSecMap.containsKey(p.id)) {
                return p.copyWith(secondaryPositions: fallbackSecMap[p.id]);
              }
              return p;
            }).toList();
            return _cachedPlayers;
          }
        }
      } catch (_) {
        // Fall back to local seed data
      }
    }

    // 2. Load from local seed JSON (offline-first & demo ready)
    final jsonString =
        await rootBundle.loadString('assets/data/default_players.json');
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    _cachedPlayers = jsonList
        .map((item) => Player.fromJson(item as Map<String, dynamic>))
        .toList();

    return _cachedPlayers;
  }

  Player? getPlayerById(String id) {
    try {
      return _cachedPlayers.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Player> searchPlayers({
    String query = '',
    String? position,
    String? playstyle,
  }) {
    return _cachedPlayers.where((player) {
      final matchesQuery = query.isEmpty ||
          player.name.toLowerCase().contains(query.toLowerCase()) ||
          player.club.toLowerCase().contains(query.toLowerCase());

      final matchesPosition = position == null ||
          position.isEmpty ||
          position == 'ALL' ||
          player.canPlayPosition(position);

      final matchesPlaystyle = playstyle == null ||
          playstyle.isEmpty ||
          playstyle == 'ALL' ||
          player.playerPlaystyle == playstyle;

      return matchesQuery && matchesPosition && matchesPlaystyle;
    }).toList();
  }

  /// Admin method: Tambah pemain baru
  /// Mengembalikan true jika berhasil tersimpan ke Supabase Cloud, false jika hanya tersimpan lokal.
  Future<bool> addPlayer(Player player) async {
    bool savedToCloud = false;
    if (SupabaseService.isInitialized) {
      final client = SupabaseService.client;
      if (client != null) {
        try {
          await client.from('players').insert(player.toJson());
          savedToCloud = true;
        } catch (e) {
          // If secondary_positions column is not yet in Supabase, retry without it
          if (e.toString().contains('secondary_positions')) {
            final jsonNoSec = Map<String, dynamic>.from(player.toJson())
              ..remove('secondary_positions');
            await client.from('players').insert(jsonNoSec);
            savedToCloud = true;
          } else {
            rethrow;
          }
        }
      }
    }

    _cachedPlayers.removeWhere((p) => p.id == player.id);
    _cachedPlayers.insert(0, player);
    return savedToCloud;
  }

  /// Admin method: Hapus pemain
  /// Mengembalikan true jika berhasil dihapus dari Supabase Cloud.
  Future<bool> deletePlayer(String playerId) async {
    bool deletedFromCloud = false;
    if (SupabaseService.isInitialized) {
      final client = SupabaseService.client;
      if (client != null) {
        try {
          await client.from('players').delete().eq('id', playerId);
          deletedFromCloud = true;
        } catch (e) {
          rethrow;
        }
      }
    }

    _cachedPlayers.removeWhere((p) => p.id == playerId);
    return deletedFromCloud;
  }
}
