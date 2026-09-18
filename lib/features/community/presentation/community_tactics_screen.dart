import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../main.dart';
import '../../squad/domain/squad.dart';
import '../../squad/presentation/squad_controller.dart';

class CommunityTacticsScreen extends ConsumerWidget {
  const CommunityTacticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communitySquadsAsync = ref.watch(communitySquadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('COMMUNITY META TACTICS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(communitySquadsProvider);
            },
          ),
        ],
      ),
      body: communitySquadsAsync.when(
        data: (squads) {
          if (squads.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada taktik komunitas.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: squads.length,
            itemBuilder: (context, index) {
              final squad = squads[index];
              return _buildCommunitySquadCard(context, ref, squad);
            },
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

  Widget _buildCommunitySquadCard(
      BuildContext context, WidgetRef ref, Squad squad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  squad.squadName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.accentGold),
                ),
                child: Text(
                  'TS ${squad.teamStrength}',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Formasi: ${squad.formation} • Taktik: ${squad.teamPlaystyle}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite,
                      color: AppColors.accentRed, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${squad.likesCount} Likes',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 11),
                ),
                icon: const Icon(Icons.download, size: 14),
                label: const Text('Salin Formasi'),
                onPressed: () {
                  ref.read(currentSquadProvider.notifier).loadSquad(squad);
                  ref.read(bottomNavIndexProvider.notifier).state = 0;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Formasi "${squad.squadName}" disalin ke Squad Builder!'),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
