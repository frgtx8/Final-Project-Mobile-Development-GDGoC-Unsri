import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/playstyles.dart';
import '../domain/player.dart';
import 'players_provider.dart';

class AdminAddPlayerDialog extends ConsumerStatefulWidget {
  const AdminAddPlayerDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AdminAddPlayerDialog(),
    );
  }

  @override
  ConsumerState<AdminAddPlayerDialog> createState() =>
      _AdminAddPlayerDialogState();
}

class _AdminAddPlayerDialogState extends ConsumerState<AdminAddPlayerDialog> {
  final _nameController = TextEditingController();
  final _clubController = TextEditingController();
  final _nationalityController = TextEditingController(text: 'Indonesia');

  String _selectedPosition = 'CF';
  String _selectedPlaystyle = Playstyles.goalPoacher;
  int _overallRating = 90;

  int _pace = 85;
  int _shooting = 85;
  int _passing = 80;
  int _dribbling = 82;
  int _defending = 60;
  int _physical = 80;

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _clubController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final name = _nameController.text.trim();
    final club = _clubController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama pemain wajib diisi!'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final newPlayer = Player(
      id: 'custom-${const Uuid().v4().substring(0, 8)}',
      name: name,
      club: club.isEmpty ? 'Custom FC' : club,
      nationality: _nationalityController.text.trim(),
      primaryPosition: _selectedPosition,
      overallRating: _overallRating,
      playerPlaystyle: _selectedPlaystyle,
      keyStats: PlayerKeyStats(
        pace: _pace,
        shooting: _shooting,
        passing: _passing,
        dribbling: _dribbling,
        defending: _defending,
        physical: _physical,
      ),
      skills: ['Double Touch', 'Fighting Spirit'],
    );

    try {
      final savedToCloud =
          await ref.read(playerRepositoryProvider).addPlayer(newPlayer);
      ref.invalidate(allPlayersProvider);

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              savedToCloud
                  ? 'Pemain "$name" berhasil disimpan ke Cloud Supabase (Tersinkron ke semua user)!'
                  : 'Pemain "$name" tersimpan di memori lokal.',
            ),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal simpan ke Supabase ($e). Pastikan RLS di Supabase Dashboard sudah diizinkan.',
            ),
            backgroundColor: AppColors.accentRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: size.height * 0.88,
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.admin_panel_settings,
                        color: AppColors.accentGold, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'TAMBAH PEMAIN (ADMIN)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: AppColors.cardBorder),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Club
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pemain (misal: Cristiano Ronaldo)',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _clubController,
                      decoration: const InputDecoration(
                        labelText: 'Klub (misal: Al Nassr)',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Position & Nationality Row
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedPosition,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Posisi',
                              isDense: true,
                            ),
                            dropdownColor: AppColors.surface,
                            items: Playstyles.allPositions
                                .map((pos) => DropdownMenuItem(
                                      value: pos,
                                      child: Text(
                                        pos,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedPosition = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _nationalityController,
                            decoration: const InputDecoration(
                              labelText: 'Negara (misal: Portugal)',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Full-width Playstyle Dropdown (No overflow, all eFootball playstyles)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPlaystyle,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Gaya Main (Playstyle eFootball)',
                        prefixIcon: Icon(
                          Icons.sports_soccer,
                          color: AppColors.primaryNeon,
                          size: 20,
                        ),
                        isDense: true,
                      ),
                      dropdownColor: AppColors.surface,
                      items: Playstyles.allPlayerPlaystyles
                          .map((ps) => DropdownMenuItem(
                                value: ps,
                                child: Text(
                                  Playstyles.getLabelWithIndonesian(ps),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedPlaystyle = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Rating Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Overall Rating (OVR):',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        Text(
                          _overallRating.toString(),
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _overallRating.toDouble(),
                      min: 65,
                      max: 99,
                      divisions: 34,
                      activeColor: AppColors.accentGold,
                      onChanged: (val) =>
                          setState(() => _overallRating = val.round()),
                    ),
                    const SizedBox(height: 10),

                    // Key Stats Sliders
                    const Text(
                      'Statistik Kunci Pemain:',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    _buildStatSlider('Pace (Kecepatan)', _pace,
                        (val) => setState(() => _pace = val)),
                    _buildStatSlider('Shooting (Menembak)', _shooting,
                        (val) => setState(() => _shooting = val)),
                    _buildStatSlider('Passing (Umpan)', _passing,
                        (val) => setState(() => _passing = val)),
                    _buildStatSlider('Dribbling (Giring Bola)', _dribbling,
                        (val) => setState(() => _dribbling = val)),
                    _buildStatSlider('Defending (Bertahan)', _defending,
                        (val) => setState(() => _defending = val)),
                    _buildStatSlider('Physical (Fisik)', _physical,
                        (val) => setState(() => _physical = val)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Simpan Pemain ke Database'),
                onPressed: _isSaving ? null : _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSlider(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 6,
            child: Slider(
              value: value.toDouble(),
              min: 40,
              max: 99,
              activeColor: AppColors.primaryNeon,
              onChanged: (val) => onChanged(val.round()),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              value.toString(),
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
