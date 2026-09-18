import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/player.dart';

class PlayerCardWidget extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;
  final bool isCompact;
  final Widget? trailing;
  final String? assignedSlot;
  final bool isCurrentSlot;
  final int? effectiveOvr;

  const PlayerCardWidget({
    super.key,
    required this.player,
    this.onTap,
    this.isCompact = false,
    this.trailing,
    this.assignedSlot,
    this.isCurrentSlot = false,
    this.effectiveOvr,
  });

  Color _getPositionColor(String position) {
    final cleanPos = position.replaceAll(RegExp(r'[0-9]'), '');
    if (['CF', 'SS', 'LWF', 'RWF'].contains(cleanPos)) {
      return AppColors.accentRed;
    } else if (['AMF', 'CMF', 'DMF', 'LMF', 'RMF'].contains(cleanPos)) {
      return AppColors.accentGreen;
    } else if (['CB', 'LB', 'RB', 'LWB', 'RWB'].contains(cleanPos)) {
      return const Color(0xFF38BDF8); // Vibrant Sky Blue
    } else {
      return AppColors.accentOrange; // GK
    }
  }

  @override
  Widget build(BuildContext context) {
    final posColor = _getPositionColor(player.primaryPosition);
    final isAssigned = isCurrentSlot || assignedSlot != null;
    final ratingToShow = effectiveOvr ?? player.overallRating;
    final isReduced = effectiveOvr != null && effectiveOvr! < player.overallRating;

    if (isCompact) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF162035),
                isCurrentSlot
                    ? AppColors.accentGreen.withValues(alpha: 0.08)
                    : (assignedSlot != null
                        ? AppColors.accentOrange.withValues(alpha: 0.08)
                        : const Color(0xFF111827)),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCurrentSlot
                  ? AppColors.accentGreen.withValues(alpha: 0.8)
                  : (assignedSlot != null
                      ? AppColors.accentOrange.withValues(alpha: 0.7)
                      : AppColors.cardBorder),
              width: isAssigned ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Position & OVR pill
              Container(
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: posColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: posColor, width: 1.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.primaryPosition,
                      style: TextStyle(
                        color: posColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      ratingToShow.toString(),
                      style: TextStyle(
                        color: isReduced ? AppColors.accentRed : AppColors.accentGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                    if (isReduced)
                      const Text(
                        '↓ penalty',
                        style: TextStyle(
                          color: AppColors.accentRed,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Player Info & Tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (player.secondaryPositions.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNeon.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Versatile',
                              style: TextStyle(
                                color: AppColors.primaryNeon,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${player.playerPlaystyle} • ${player.club}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Badges row: Assigned status & Versatile secondary positions
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        if (isCurrentSlot)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.accentGreen, width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 10, color: AppColors.accentGreen),
                                SizedBox(width: 3),
                                Text(
                                  'Terpasang di sini',
                                  style: TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (assignedSlot != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.accentOrange, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sports_soccer, size: 10, color: AppColors.accentOrange),
                                const SizedBox(width: 3),
                                Text(
                                  'Terpakai di: $assignedSlot',
                                  style: const TextStyle(
                                    color: AppColors.accentOrange,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (player.secondaryPositions.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.cardBorder, width: 0.8),
                            ),
                            child: Text(
                              'Alt: ${player.secondaryPositions.join(", ")}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 6),
                trailing!,
              ],
            ],
          ),
        ),
      );
    }

    // Full Card View (Used in Player Database & Squad Screens)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF162035),
              Color(0xFF101726),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Position & OVR Card
                Container(
                  width: 54,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: posColor, width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: posColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        player.primaryPosition,
                        style: TextStyle(
                          color: posColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        player.overallRating.toString(),
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Player Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (player.secondaryPositions.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNeon.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Versatile',
                                style: TextStyle(
                                  color: AppColors.primaryNeon,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${player.club} • ${player.nationality}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.cardBorder, width: 0.8),
                            ),
                            child: Text(
                              player.playerPlaystyle,
                              style: const TextStyle(
                                color: AppColors.primaryNeon,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (player.secondaryPositions.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.cardBorder, width: 0.8),
                              ),
                              child: Text(
                                'Alt: ${player.secondaryPositions.join(" • ")}',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 10),
            // Key Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('PAC', player.keyStats.pace),
                _buildStatItem('SHO', player.keyStats.shooting),
                _buildStatItem('PAS', player.keyStats.passing),
                _buildStatItem('DRI', player.keyStats.dribbling),
                _buildStatItem('DEF', player.keyStats.defending),
                _buildStatItem('PHY', player.keyStats.physical),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    Color valColor = AppColors.textPrimary;
    if (value >= 90) {
      valColor = AppColors.accentGreen;
    } else if (value >= 80) {
      valColor = AppColors.accentGold;
    } else if (value < 65) {
      valColor = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value.toString(),
            style: TextStyle(
              color: valColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
