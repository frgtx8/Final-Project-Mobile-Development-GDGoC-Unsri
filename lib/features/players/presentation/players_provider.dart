import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/player_repository.dart';
import '../domain/player.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository();
});

class PlayerFilterState {
  final String query;
  final String selectedPosition;
  final String selectedPlaystyle;

  const PlayerFilterState({
    this.query = '',
    this.selectedPosition = 'ALL',
    this.selectedPlaystyle = 'ALL',
  });

  PlayerFilterState copyWith({
    String? query,
    String? selectedPosition,
    String? selectedPlaystyle,
  }) {
    return PlayerFilterState(
      query: query ?? this.query,
      selectedPosition: selectedPosition ?? this.selectedPosition,
      selectedPlaystyle: selectedPlaystyle ?? this.selectedPlaystyle,
    );
  }
}

final playerFilterProvider =
    StateProvider<PlayerFilterState>((ref) => const PlayerFilterState());

final allPlayersProvider = FutureProvider<List<Player>>((ref) async {
  final repo = ref.watch(playerRepositoryProvider);
  return await repo.loadPlayers(forceRefresh: true);
});

final filteredPlayersProvider = Provider<List<Player>>((ref) {
  final playersAsync = ref.watch(allPlayersProvider);
  final filter = ref.watch(playerFilterProvider);

  return playersAsync.maybeWhen(
    data: (players) {
      return players.where((p) {
        final matchesQuery = filter.query.isEmpty ||
            p.name.toLowerCase().contains(filter.query.toLowerCase()) ||
            p.club.toLowerCase().contains(filter.query.toLowerCase());

        final matchesPosition = filter.selectedPosition == 'ALL' ||
            p.canPlayPosition(filter.selectedPosition);

        final matchesPlaystyle = filter.selectedPlaystyle == 'ALL' ||
            p.playerPlaystyle == filter.selectedPlaystyle;

        return matchesQuery && matchesPosition && matchesPlaystyle;
      }).toList();
    },
    orElse: () => [],
  );
});
