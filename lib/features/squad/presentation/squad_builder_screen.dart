import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/formations.dart';
import '../../../core/constants/playstyles.dart';
import '../../ai_coach/presentation/ai_coach_provider.dart';
import '../../ai_coach/presentation/ai_doctor_modal.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../players/presentation/players_provider.dart';
import 'admin_add_formation_dialog.dart';
import 'formations_provider.dart';
import 'squad_controller.dart';
import 'tactical_pitch_widget.dart';

class SquadBuilderScreen extends ConsumerStatefulWidget {
  const SquadBuilderScreen({super.key});

  @override
  ConsumerState<SquadBuilderScreen> createState() => _SquadBuilderScreenState();
}

class _SquadBuilderScreenState extends ConsumerState<SquadBuilderScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(currentSquadProvider).squadName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showEditSquadNameDialog(BuildContext context) {
    _nameController.text = ref.read(currentSquadProvider).squadName;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Ubah Nama Skuad',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama skuad...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                ref
                    .read(currentSquadProvider.notifier)
                    .setSquadName(_nameController.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleRunAIDoctor() async {
    final aiController = ref.read(aiDoctorControllerProvider.notifier);
    final squad = ref.read(currentSquadProvider);

    final report = await aiController.runSynergyAnalysis();
    if (!mounted) return;

    if (report != null) {
      AIDoctorModal.show(
        context,
        report: report,
        squadName: squad.squadName,
        formation: squad.formation,
        teamPlaystyle: squad.teamPlaystyle,
      );
    } else {
      final error = ref.read(aiDoctorControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menjalankan analisis AI.'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  void _confirmResetSquad(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt, color: AppColors.accentGold),
            SizedBox(width: 8),
            Text(
              'Mulai Skuad Baru?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin mengatur ulang formasi & susunan pemain ke posisi awal?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(currentSquadProvider.notifier).resetSquad();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Skuad berhasil direset ke susunan awal.'),
                  backgroundColor: AppColors.surfaceLight,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reset Skuad'),
          ),
        ],
      ),
    );
  }

  void _handleSaveSquad() async {
    final success =
        await ref.read(currentSquadProvider.notifier).saveSquad(isPublic: true);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skuad berhasil disimpan ke Cloud Supabase!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } else {
      final error = ref.read(currentSquadProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menyimpan skuad.'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final squadState = ref.watch(currentSquadProvider);
    final teamStrength = ref.watch(currentTeamStrengthProvider);
    final playersAsync = ref.watch(allPlayersProvider);
    final aiState = ref.watch(aiDoctorControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.user?.isAdmin ?? false;
    final formationsList =
        ref.watch(availableFormationsProvider).value ?? Formations.allFormations;

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _showEditSquadNameDialog(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                squadState.squadName,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
        actions: [
          // Team Strength Badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentGold, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TS: ',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  teamStrength.toString(),
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          // Reset / New Squad Button
          IconButton(
            tooltip: 'Reset / Skuad Baru',
            icon: const Icon(Icons.restart_alt, color: AppColors.textSecondary),
            onPressed: () => _confirmResetSquad(context),
          ),
          // Save Button
          IconButton(
            tooltip: 'Simpan Skuad ke Cloud',
            icon: squadState.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined,
                    color: AppColors.primaryNeon),
            onPressed: squadState.isSaving ? null : _handleSaveSquad,
          ),
        ],
      ),
      body: playersAsync.when(
        data: (players) {
          final playersMap = {for (final p in players) p.id: p};

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Formation & Playstyle Selectors Row
                Row(
                  children: [
                    // Formation Dropdown
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: formationsList.contains(squadState.formation)
                                ? squadState.formation
                                : formationsList.first,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.primaryNeon),
                            items: formationsList.map((f) {
                              return DropdownMenuItem(
                                value: f,
                                child: Text(
                                  f,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newFormation) {
                              if (newFormation != null) {
                                ref
                                    .read(currentSquadProvider.notifier)
                                    .setFormation(newFormation);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Tambah Formasi Cloud (Admin)',
                        icon: const Icon(Icons.add_circle,
                            color: AppColors.accentGold, size: 22),
                        onPressed: () => AdminAddFormationDialog.show(context),
                      ),
                    ],
                    const SizedBox(width: 10),
                    // Playstyle Dropdown
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: squadState.teamPlaystyle,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.accentGold),
                            items: Playstyles.allTeamPlaystyles.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (newPlaystyle) {
                              if (newPlaystyle != null) {
                                ref
                                    .read(currentSquadProvider.notifier)
                                    .setTeamPlaystyle(newPlaystyle);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Interactive Tactical Pitch
                TacticalPitchWidget(
                  formation: squadState.formation,
                  startingEleven: squadState.startingEleven,
                  playersById: playersMap,
                  onPlayerAssigned: (slotId, playerId) {
                    ref
                        .read(currentSquadProvider.notifier)
                        .assignPlayerToSlot(slotId, playerId);
                  },
                ),
                const SizedBox(height: 16),

                // FITUR KUNCI: AI SQUAD DOCTOR CTA BUTTON
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryNeon,
                        AppColors.accentGreen,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNeon.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        aiState.isAnalyzing ? null : _handleRunAIDoctor,
                    child: aiState.isAnalyzing
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'AI sedang menganalisis sinergi skuad...',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.psychology,
                                  color: Colors.black, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'ANALISIS SINERGI SKUAD (AI DOCTOR)',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: AppColors.accentRed),
          ),
        ),
      ),
    );
  }
}
