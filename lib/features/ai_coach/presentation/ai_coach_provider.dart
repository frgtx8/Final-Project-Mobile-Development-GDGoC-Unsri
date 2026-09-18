import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../players/domain/player.dart';
import '../../players/presentation/players_provider.dart';
import '../../squad/presentation/squad_controller.dart';
import '../data/gemini_ai_service.dart';
import '../domain/squad_synergy_report.dart';

final geminiAIServiceProvider = Provider<GeminiAIService>((ref) {
  return GeminiAIService();
});

class AIDoctorState {
  final bool isAnalyzing;
  final SquadSynergyReport? report;
  final String? errorMessage;

  const AIDoctorState({
    this.isAnalyzing = false,
    this.report,
    this.errorMessage,
  });

  AIDoctorState copyWith({
    bool? isAnalyzing,
    SquadSynergyReport? report,
    String? errorMessage,
  }) {
    return AIDoctorState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      report: report ?? this.report,
      errorMessage: errorMessage,
    );
  }
}

class AIDoctorController extends StateNotifier<AIDoctorState> {
  final GeminiAIService _aiService;
  final Ref _ref;

  AIDoctorController(this._aiService, this._ref)
      : super(const AIDoctorState());

  Future<SquadSynergyReport?> runSynergyAnalysis() async {
    state = state.copyWith(isAnalyzing: true, errorMessage: null);

    try {
      final squad = _ref.read(currentSquadProvider);
      final players = _ref.read(allPlayersProvider).value ?? [];
      final playersMap = {for (final p in players) p.id: p};

      final lineUp = <String, Player>{};
      for (final entry in squad.startingEleven.entries) {
        final player = playersMap[entry.value];
        if (player != null) {
          lineUp[entry.key] = player;
        }
      }

      final report = await _aiService.analyzeSquadSynergy(
        formation: squad.formation,
        teamPlaystyle: squad.teamPlaystyle,
        lineUpWithPositions: lineUp,
      );

      state = state.copyWith(isAnalyzing: false, report: report);
      return report;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Gagal menganalisis skuad: ${e.toString()}',
      );
      return null;
    }
  }

  void clearReport() {
    state = const AIDoctorState();
  }
}

final aiDoctorControllerProvider =
    StateNotifierProvider<AIDoctorController, AIDoctorState>((ref) {
  final aiService = ref.watch(geminiAIServiceProvider);
  return AIDoctorController(aiService, ref);
});

class AIScoutState {
  final bool isLoading;
  final String? responseText;
  final String? errorMessage;

  const AIScoutState({
    this.isLoading = false,
    this.responseText,
    this.errorMessage,
  });

  AIScoutState copyWith({
    bool? isLoading,
    String? responseText,
    String? errorMessage,
  }) {
    return AIScoutState(
      isLoading: isLoading ?? this.isLoading,
      responseText: responseText ?? this.responseText,
      errorMessage: errorMessage,
    );
  }
}

class AIScoutController extends StateNotifier<AIScoutState> {
  final GeminiAIService _aiService;
  final Ref _ref;

  AIScoutController(this._aiService, this._ref) : super(const AIScoutState());

  Future<void> askScout(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final squad = _ref.read(currentSquadProvider);
      final players = _ref.read(allPlayersProvider).value ?? [];
      final response = await _aiService.askPlayerScoutAdvice(
        query: query,
        currentPlaystyle: squad.teamPlaystyle,
        catalog: players,
      );
      state = state.copyWith(isLoading: false, responseText: response);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memproses pertanyaan: ${e.toString()}',
      );
    }
  }

  void clear() {
    state = const AIScoutState();
  }
}

final aiScoutControllerProvider =
    StateNotifierProvider<AIScoutController, AIScoutState>((ref) {
  final aiService = ref.watch(geminiAIServiceProvider);
  return AIScoutController(aiService, ref);
});
