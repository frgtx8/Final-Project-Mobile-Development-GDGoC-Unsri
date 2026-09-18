import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/player.dart';

class PlayerDetailModal extends StatelessWidget {
  final Player player;

  const PlayerDetailModal({super.key, required this.player});

  static void show(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PlayerDetailModal(player: player),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header info
          Row(
            children: [
              Container(
                width: 60,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentGold, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      player.primaryPosition,
                      style: const TextStyle(
                        color: AppColors.primaryNeon,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      player.overallRating.toString(),
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${player.club} • ${player.nationality}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gaya Main: ${player.playerPlaystyle}',
                      style: const TextStyle(
                        color: AppColors.primaryNeon,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (player.secondaryPositions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Posisi Lain: ${player.secondaryPositions.join(", ")}',
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Statistik Kunci eFootball',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildStatBar('Pace (Kecepatan)', player.keyStats.pace),
          _buildStatBar('Shooting (Penyelesaian)', player.keyStats.shooting),
          _buildStatBar('Passing (Umpan)', player.keyStats.passing),
          _buildStatBar('Dribbling (Kelincahan)', player.keyStats.dribbling),
          _buildStatBar('Defending (Bertahan)', player.keyStats.defending),
          _buildStatBar('Physical (Kekuatan Fisik)', player.keyStats.physical),
          const SizedBox(height: 16),
          if (player.skills.isNotEmpty) ...[
            const Text(
              'Keahlian Khusus (Player Skills)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: player.skills.map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value) {
    Color barColor = AppColors.primaryNeon;
    if (value >= 90) {
      barColor = AppColors.accentGreen;
    } else if (value >= 80) {
      barColor = AppColors.accentGold;
    } else if (value < 65) {
      barColor = AppColors.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
