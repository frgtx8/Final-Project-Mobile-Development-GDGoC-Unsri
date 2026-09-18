import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/squad_synergy_report.dart';
import 'synergy_score_badge.dart';

class AIDoctorModal extends StatelessWidget {
  final SquadSynergyReport report;
  final String squadName;
  final String formation;
  final String teamPlaystyle;

  const AIDoctorModal({
    super.key,
    required this.report,
    required this.squadName,
    required this.formation,
    required this.teamPlaystyle,
  });

  static void show(
    BuildContext context, {
    required SquadSynergyReport report,
    required String squadName,
    required String formation,
    required String teamPlaystyle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      enableDrag: false, // Prevents bottom sheet gesture detector from blocking vertical ListView scroll
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AIDoctorModal(
        report: report,
        squadName: squadName,
        formation: formation,
        teamPlaystyle: teamPlaystyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag Indicator
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Smoothly scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                // Flagship Header
                Row(
                  children: [
                    SynergyScoreBadge(
                      score: report.synergyScore,
                      grade: report.grade,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.psychology,
                                color: AppColors.primaryNeon,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'AI SQUAD DOCTOR',
                                style: TextStyle(
                                  color: AppColors.primaryNeon,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            squadName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$formation • $teamPlaystyle',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tactical Verdict Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.sports_soccer,
                              color: AppColors.primaryNeon, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Diagnosa Taktikal:',
                            style: TextStyle(
                              color: AppColors.primaryNeon,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.tacticalVerdict,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Kekuatan Taktik (Strengths)
                if (report.strengths.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Kelebihan Skuad',
                    icon: Icons.check_circle_outline,
                    color: AppColors.accentGreen,
                  ),
                  const SizedBox(height: 8),
                  ...report.strengths.map(
                    (str) => _buildBulletItem(
                      text: str,
                      icon: Icons.check,
                      iconColor: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Red Flags (Weaknesses / Spasial Celah)
                if (report.weaknesses.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Celah / Red Flags di eFootball',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.accentRed,
                  ),
                  const SizedBox(height: 8),
                  ...report.weaknesses.map(
                    (weak) => _buildBulletItem(
                      text: weak,
                      icon: Icons.close,
                      iconColor: AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Instruksi Individual Taktis
                if (report.tacticalInstructions.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Rekomendasi Instruksi In-Game',
                    icon: Icons.alt_route,
                    color: AppColors.primaryNeon,
                  ),
                  const SizedBox(height: 8),
                  ...report.tacticalInstructions.map(
                    (inst) => _buildBulletItem(
                      text: inst,
                      icon: Icons.arrow_right,
                      iconColor: AppColors.primaryNeon,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Rekomendasi Pemain Pengganti
                if (report.alternativeSuggestions.isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'Saran Pemain Alternatif',
                    icon: Icons.swap_horizontal_circle_outlined,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(height: 8),
                  ...report.alternativeSuggestions.map(
                    (alt) => _buildBulletItem(
                      text: alt,
                      icon: Icons.person_search,
                      iconColor: AppColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),

          // Pinned Bottom Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup Analisis'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem({
    required String text,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
