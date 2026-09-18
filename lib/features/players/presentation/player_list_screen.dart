import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/playstyles.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/player.dart';
import 'admin_add_player_dialog.dart';
import 'player_card_widget.dart';
import 'player_detail_modal.dart';
import 'players_provider.dart';

class PlayerListScreen extends ConsumerWidget {
  const PlayerListScreen({super.key});

  void _confirmDelete(BuildContext context, WidgetRef ref, Player player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Hapus Pemain (Admin)',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${player.name}" dari database?',
          style: const TextStyle(color: AppColors.textSecondary),
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
            onPressed: () async {
              try {
                final deletedFromCloud = await ref
                    .read(playerRepositoryProvider)
                    .deletePlayer(player.id);
                ref.invalidate(allPlayersProvider);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        deletedFromCloud
                            ? 'Pemain "${player.name}" berhasil dihapus dari Cloud Supabase!'
                            : 'Pemain "${player.name}" dihapus dari daftar lokal.',
                      ),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus dari Cloud Supabase ($e).'),
                      backgroundColor: AppColors.accentRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredPlayers = ref.watch(filteredPlayersProvider);
    final filterState = ref.watch(playerFilterProvider);
    final allPlayersAsync = ref.watch(allPlayersProvider);
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DATABASE PEMAIN eFOOTBALL'),
        centerTitle: true,
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Tambah Pemain Baru',
              icon: const Icon(Icons.person_add, color: AppColors.accentGold),
              onPressed: () => AdminAddPlayerDialog.show(context),
            ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accentGold,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text(
                'Tambah Pemain',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => AdminAddPlayerDialog.show(context),
            )
          : null,
      body: Column(
        children: [
          // Admin Status Banner (if logged in as admin)
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.accentGold.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings,
                      color: AppColors.accentGold, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Mode Admin Aktif: Anda dapat menambah & menghapus pemain.',
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () => AdminAddPlayerDialog.show(context),
                    child: const Text(
                      '+ Tambah',
                      style: TextStyle(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Search & Filter Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) {
                    ref.read(playerFilterProvider.notifier).state =
                        filterState.copyWith(query: val);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Cari pemain, klub, atau negara...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                // Position Filter Chips (Horizontal scroll)
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPosChip(ref, 'ALL', filterState.selectedPosition),
                      ...Playstyles.allPositions.map(
                        (pos) => _buildPosChip(
                            ref, pos, filterState.selectedPosition),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Playstyle Filter Chips (Horizontal scroll)
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPlaystyleChip(
                          ref, 'ALL', filterState.selectedPlaystyle),
                      ...Playstyles.allPlayerPlaystyles.map(
                        (ps) => _buildPlaystyleChip(
                            ref, ps, filterState.selectedPlaystyle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Player count bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ditemukan ${filteredPlayers.length} pemain',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                allPlayersAsync.maybeWhen(
                  data: (players) => Text(
                    'Total Database: ${players.length}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // Player List
          Expanded(
            child: allPlayersAsync.when(
              data: (_) {
                if (filteredPlayers.isEmpty) {
                  return const Center(
                    child: Text(
                      'Pemain tidak ditemukan.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryNeon,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    await ref
                        .read(playerRepositoryProvider)
                        .loadPlayers(forceRefresh: true);
                    ref.invalidate(allPlayersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPlayers.length,
                    itemBuilder: (context, index) {
                      final player = filteredPlayers[index];
                      return PlayerCardWidget(
                        player: player,
                        onTap: () => PlayerDetailModal.show(context, player),
                        trailing: isAdmin
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.accentRed,
                                  size: 20,
                                ),
                                tooltip: 'Hapus Pemain (Admin)',
                                onPressed: () =>
                                    _confirmDelete(context, ref, player),
                              )
                            : null,
                      );
                    },
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Error memuat pemain: $err',
                  style: const TextStyle(color: AppColors.accentRed),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosChip(
      WidgetRef ref, String position, String currentSelected) {
    final isSelected = position == currentSelected;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          position,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primaryNeon,
        backgroundColor: AppColors.surfaceLight,
        side: BorderSide(
          color: isSelected ? AppColors.primaryNeon : AppColors.cardBorder,
        ),
        onSelected: (selected) {
          if (selected) {
            ref.read(playerFilterProvider.notifier).state = ref
                .read(playerFilterProvider)
                .copyWith(selectedPosition: position);
          }
        },
      ),
    );
  }

  Widget _buildPlaystyleChip(
      WidgetRef ref, String playstyle, String currentSelected) {
    final isSelected = playstyle == currentSelected;
    final label = playstyle == 'ALL'
        ? 'Semua Gaya Main'
        : Playstyles.getLabelWithIndonesian(playstyle);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.accentGold,
        backgroundColor: AppColors.surfaceLight,
        side: BorderSide(
          color: isSelected ? AppColors.accentGold : AppColors.cardBorder,
        ),
        onSelected: (selected) {
          if (selected) {
            ref.read(playerFilterProvider.notifier).state = ref
                .read(playerFilterProvider)
                .copyWith(selectedPlaystyle: playstyle);
          }
        },
      ),
    );
  }
}
