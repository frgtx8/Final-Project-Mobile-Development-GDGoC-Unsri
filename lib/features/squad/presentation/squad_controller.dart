import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/formations.dart';
import '../../../core/constants/playstyles.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../players/presentation/players_provider.dart';
import '../data/squad_repository.dart';
import '../domain/squad.dart';

final squadRepositoryProvider = Provider<SquadRepository>((ref) {
  return SquadRepository();
});

class CurrentSquadState {
  final String id;
  final String squadName;
  final String formation;
  final String teamPlaystyle;
  final Map<String, String> startingEleven; // Map<SlotId, PlayerId>
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CurrentSquadState({
    required this.id,
    this.squadName = 'Ultimate eFooty XI',
    this.formation = Formations.f4213,
    this.teamPlaystyle = Playstyles.quickCounter,
    this.startingEleven = const {},
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  CurrentSquadState copyWith({
    String? id,
    String? squadName,
    String? formation,
    String? teamPlaystyle,
    Map<String, String>? startingEleven,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CurrentSquadState(
      id: id ?? this.id,
      squadName: squadName ?? this.squadName,
      formation: formation ?? this.formation,
      teamPlaystyle: teamPlaystyle ?? this.teamPlaystyle,
      startingEleven: startingEleven ?? this.startingEleven,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class SquadController extends StateNotifier<CurrentSquadState> {
  final Ref _ref;

  SquadController(this._ref)
      : super(CurrentSquadState(
          id: const Uuid().v4(),
          startingEleven: _getDefaultStarterXI(),
        ));

  static Map<String, String> _getDefaultStarterXI() {
    return {
      'GK': 'p-012',
      'LB': 'p-010',
      'CB1': 'p-008',
      'CB2': 'p-009',
      'RB': 'p-011',
      'DMF1': 'p-006',
      'DMF2': 'p-007',
      'AMF': 'p-005',
      'LWF': 'p-002',
      'CF': 'p-001',
      'RWF': 'p-003',
    };
  }

  void setFormation(String formation) {
    // Keep compatible players or adjust slots
    final newSlots = Formations.getSlots(formation);
    final updatedXI = <String, String>{};

    for (final slot in newSlots) {
      if (state.startingEleven.containsKey(slot.id)) {
        updatedXI[slot.id] = state.startingEleven[slot.id]!;
      }
    }

    state = state.copyWith(
      formation: formation,
      startingEleven: updatedXI,
      clearMessages: true,
    );
  }

  void setTeamPlaystyle(String playstyle) {
    state = state.copyWith(
      teamPlaystyle: playstyle,
      clearMessages: true,
    );
  }

  void setSquadName(String name) {
    state = state.copyWith(
      squadName: name,
      clearMessages: true,
    );
  }

  void assignPlayerToSlot(String slotId, String playerId) {
    final updatedXI = Map<String, String>.from(state.startingEleven);
    // Remove player if already in another slot
    updatedXI.removeWhere((key, value) => value == playerId);
    updatedXI[slotId] = playerId;

    state = state.copyWith(
      startingEleven: updatedXI,
      clearMessages: true,
    );
  }

  void removePlayerFromSlot(String slotId) {
    final updatedXI = Map<String, String>.from(state.startingEleven);
    updatedXI.remove(slotId);
    state = state.copyWith(
      startingEleven: updatedXI,
      clearMessages: true,
    );
  }

  void loadSquad(Squad squad) {
    state = CurrentSquadState(
      id: squad.id,
      squadName: squad.squadName,
      formation: squad.formation,
      teamPlaystyle: squad.teamPlaystyle,
      startingEleven: Map<String, String>.from(squad.startingEleven),
    );
  }

  void resetSquad() {
    state = CurrentSquadState(
      id: const Uuid().v4(),
      startingEleven: _getDefaultStarterXI(),
    );
  }

  Future<bool> saveSquad({bool isPublic = false}) async {
    state = state.copyWith(isSaving: true, clearMessages: true);

    try {
      final authState = _ref.read(authControllerProvider);
      final userId = authState.user?.id ?? 'guest-user-id';
      final players = _ref.read(allPlayersProvider).value ?? [];
      final playersMap = {for (final p in players) p.id: p};

      final slots = Formations.getSlots(state.formation);
      final slotPosMap = {for (final s in slots) s.id: s.defaultPosition};

      final teamStrength = Squad.calculateTeamStrength(
        state.startingEleven,
        playersMap,
        slotPositions: slotPosMap,
      );

      final squad = Squad(
        id: state.id,
        userId: userId,
        squadName: state.squadName,
        formation: state.formation,
        teamPlaystyle: state.teamPlaystyle,
        startingEleven: state.startingEleven,
        teamStrength: teamStrength,
        isPublic: isPublic,
        createdAt: DateTime.now(),
      );

      final repo = _ref.read(squadRepositoryProvider);
      await repo.saveSquad(squad);

      // Invalidate squads list to trigger refresh
      _ref.invalidate(userSquadsProvider);
      _ref.invalidate(communitySquadsProvider);

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Skuad berhasil disimpan!',
        clearMessages: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Gagal menyimpan skuad: ${e.toString()}',
        clearMessages: false,
      );
      return false;
    }
  }
}

final currentSquadProvider =
    StateNotifierProvider<SquadController, CurrentSquadState>((ref) {
  return SquadController(ref);
});

final currentTeamStrengthProvider = Provider<int>((ref) {
  final currentSquad = ref.watch(currentSquadProvider);
  final players = ref.watch(allPlayersProvider).value ?? [];
  final playersMap = {for (final p in players) p.id: p};

  final slots = Formations.getSlots(currentSquad.formation);
  final slotPosMap = {for (final s in slots) s.id: s.defaultPosition};

  return Squad.calculateTeamStrength(
    currentSquad.startingEleven,
    playersMap,
    slotPositions: slotPosMap,
  );
});

final userSquadsProvider = FutureProvider<List<Squad>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.user?.id ?? 'guest-user-id';
  final repo = ref.watch(squadRepositoryProvider);
  return await repo.getUserSquads(userId);
});

final communitySquadsProvider = FutureProvider<List<Squad>>((ref) async {
  final repo = ref.watch(squadRepositoryProvider);
  return await repo.getCommunitySquads();
});
