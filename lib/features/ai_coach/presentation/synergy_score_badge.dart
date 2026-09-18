import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SynergyScoreBadge extends StatelessWidget {
  final int score;
  final String grade;
  final bool isCompact;

  const SynergyScoreBadge({
    super.key,
    required this.score,
    required this.grade,
    this.isCompact = false,
  });

  Color get _badgeColor {
    switch (grade.toUpperCase()) {
      case 'S':
        return AppColors.accentGold;
      case 'A':
        return AppColors.accentGreen;
      case 'B':
        return AppColors.primaryNeon;
      case 'C':
      default:
        return AppColors.accentOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _badgeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _badgeColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Grade $grade',
              style: TextStyle(
                color: _badgeColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($score)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: _badgeColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: _badgeColor.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            grade,
            style: TextStyle(
              color: _badgeColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$score/100',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
