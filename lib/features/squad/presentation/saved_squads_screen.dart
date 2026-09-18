import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../main.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/presentation/auth_screen.dart';
import '../domain/squad.dart';
import 'squad_controller.dart';

class SavedSquadsScreen extends ConsumerWidget {
  const SavedSquadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userSquadsAsync = ref.watch(userSquadsProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('KOLEKSI SKUAD SAYA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(userSquadsProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryNeon.withValues(alpha: 0.2),
                    child: const Icon(Icons.sports_soccer,
                        color: AppColors.primaryNeon, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? 'Manager',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.isGuest == true
                              ? 'Mode Solo (Tamu)'
                              : (user?.email ?? ''),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (user?.isAdmin ?? false)
                                    ? AppColors.accentGold.withValues(alpha: 0.2)
                                    : AppColors.primaryNeon.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: (user?.isAdmin ?? false)
                                      ? AppColors.accentGold
                                      : AppColors.primaryNeon,
                                ),
                              ),
                              child: Text(
                                (user?.isAdmin ?? false)
                                    ? '👑 ADMIN'
                                    : '⚽ MANAGER',
                                style: TextStyle(
                                  color: (user?.isAdmin ?? false)
                                      ? AppColors.accentGold
                                      : AppColors.primaryNeon,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Klub: ${user?.favoriteClub ?? 'Real Madrid'}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (user == null || user.isGuest) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AuthScreen()),
                            );
                          } else {
                            ref.read(authControllerProvider.notifier).signOut();
                          }
                        },
                        child: Text(
                          user == null || user.isGuest ? 'Login' : 'Keluar',
                          style: const TextStyle(color: AppColors.primaryNeon),
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                          side: BorderSide(
                            color: (user?.isAdmin ?? false)
                                ? AppColors.accentGold
                                : AppColors.cardBorder,
                          ),
                        ),
                        onPressed: () {
                          ref
                              .read(authControllerProvider.notifier)
                              .toggleAdmin();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                (user?.isAdmin ?? false)
                                    ? 'Beralih ke Mode Manager Biasa.'
                                    : 'Beralih ke Mode ADMIN! Anda sekarang bisa menambah/menghapus pemain.',
                              ),
                              backgroundColor: (user?.isAdmin ?? false)
                                  ? AppColors.primaryNeon
                                  : AppColors.accentGold,
                            ),
                          );
                        },
                        child: Text(
                          (user?.isAdmin ?? false)
                              ? 'Mode User'
                              : 'Mode Admin',
                          style: TextStyle(
                            fontSize: 10,
                            color: (user?.isAdmin ?? false)
                                ? AppColors.accentGold
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Daftar Skuad Tersimpan:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),

            // Saved Squads List
            userSquadsAsync.when(
              data: (squads) {
                if (squads.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada skuad yang disimpan.\nBuat dan simpan skuad pertama Anda di Squad Builder!',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.sports_soccer),
                            label: const Text('Buka Squad Builder'),
                            onPressed: () {
                              // Switch smoothly to Squad Builder tab without resetting current players
                              ref.read(bottomNavIndexProvider.notifier).state = 0;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: squads.map((squad) {
                    return _buildSavedSquadCard(context, ref, squad);
                  }).toList(),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text(
                'Error: $err',
                style: const TextStyle(color: AppColors.accentRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedSquadCard(
      BuildContext context, WidgetRef ref, Squad squad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  squad.squadName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${squad.formation} • ${squad.teamPlaystyle} • TS ${squad.teamStrength}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Terapkan ke Pitch',
            icon: const Icon(Icons.sports_soccer, color: AppColors.primaryNeon),
            onPressed: () {
              ref.read(currentSquadProvider.notifier).loadSquad(squad);
              ref.read(bottomNavIndexProvider.notifier).state = 0;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Skuad "${squad.squadName}" dimuat ke Squad Builder!'),
                  backgroundColor: AppColors.accentGreen,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Hapus Skuad',
            icon: const Icon(Icons.delete_outline,
                color: AppColors.accentRed, size: 20),
            onPressed: () async {
              await ref
                  .read(squadRepositoryProvider)
                  .deleteSquad(squad.id);
              ref.invalidate(userSquadsProvider);
            },
          ),
        ],
      ),
    );
  }
}
