import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/formations.dart';
import '../../players/domain/player.dart';
import '../../players/presentation/player_detail_modal.dart';
import '../../players/presentation/player_picker_bottom_sheet.dart';

class TacticalPitchWidget extends StatelessWidget {
  final String formation;
  final Map<String, String> startingEleven; // Map<SlotId, PlayerId>
  final Map<String, Player> playersById;
  final Function(String slotId, String playerId) onPlayerAssigned;

  const TacticalPitchWidget({
    super.key,
    required this.formation,
    required this.startingEleven,
    required this.playersById,
    required this.onPlayerAssigned,
  });

  @override
  Widget build(BuildContext context) {
    final slots = Formations.getSlots(formation);

    return LayoutBuilder(
      builder: (context, constraints) {
        final pitchWidth = constraints.maxWidth;
        // 4:3 pitch ratio or fixed height for mobile screens
        final pitchHeight = (pitchWidth * 1.35).clamp(380.0, 520.0);

        return Container(
          width: pitchWidth,
          height: pitchHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
              width: 2,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF156937),
                Color(0xFF0D4222),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Pitch Markings (Lines)
              CustomPaint(
                size: Size(pitchWidth, pitchHeight),
                painter: _PitchPainter(),
              ),

              // 2. Interactive Player Pins
              ...slots.map((slot) {
                final playerId = startingEleven[slot.id];
                final player =
                    playerId != null ? playersById[playerId] : null;

                // Center the pin around (x * width, y * height)
                final left = slot.x * pitchWidth - 36;
                final top = slot.y * pitchHeight - 34;

                return Positioned(
                  left: left,
                  top: top,
                  child: _buildPlayerPin(
                    context,
                    slot: slot,
                    player: player,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerPin(
    BuildContext context, {
    required PitchSlot slot,
    Player? player,
  }) {
    final isOccupied = player != null;
    final effectiveOvr = isOccupied ? player.getEffectiveRating(slot.defaultPosition) : 0;
    final isOutOfPosition = isOccupied && effectiveOvr < player.overallRating;

    Color posColor = const Color(0xFF38BDF8); // Defenders
    if (['CF', 'SS', 'LWF', 'RWF'].contains(slot.defaultPosition)) {
      posColor = AppColors.accentRed;
    } else if (['AMF', 'CMF', 'LMF', 'RMF'].contains(slot.defaultPosition)) {
      posColor = AppColors.accentGreen;
    } else if (['GK'].contains(slot.defaultPosition)) {
      posColor = AppColors.accentOrange;
    }

    return GestureDetector(
      onTap: () {
        PlayerPickerBottomSheet.show(
          context,
          slotId: slot.id,
          defaultPosition: slot.defaultPosition,
          onPlayerSelected: (selectedPlayer) {
            onPlayerAssigned(slot.id, selectedPlayer.id);
          },
        );
      },
      onLongPress: () {
        if (player != null) {
          PlayerDetailModal.show(context, player);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pin Avatar / Badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isOccupied
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF131B2E), const Color(0xFF0B101D)],
              ),
              border: Border.all(
                color: isOccupied
                    ? (isOutOfPosition ? AppColors.accentRed : posColor)
                    : AppColors.cardBorder.withValues(alpha: 0.8),
                width: isOutOfPosition ? 2.5 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isOutOfPosition
                      ? AppColors.accentRed.withValues(alpha: 0.5)
                      : (isOccupied
                          ? posColor.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: 0.5)),
                  blurRadius: isOccupied ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isOccupied)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        player.primaryPosition,
                        style: TextStyle(
                          color: isOutOfPosition ? AppColors.accentRed : posColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            effectiveOvr.toString(),
                            style: TextStyle(
                              color: isOutOfPosition
                                  ? AppColors.accentRed
                                  : AppColors.accentGold,
                              fontSize: isOutOfPosition ? 13 : 15,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          if (isOutOfPosition)
                            const Text(
                              '↓',
                              style: TextStyle(
                                color: AppColors.accentRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: posColor, size: 16),
                      Text(
                        slot.defaultPosition,
                        style: TextStyle(
                          color: posColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          // Player Name Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F1D).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.cardBorder.withValues(alpha: 0.6),
                width: 0.6,
              ),
            ),
            constraints: const BoxConstraints(maxWidth: 72),
            child: Text(
              isOccupied ? player.name : slot.id,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          if (isOutOfPosition) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '-${player.overallRating - effectiveOvr} OVR',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.pitchLines
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Grass mowing stripes (8 alternating broadcast emerald bands)
    final stripePaint = Paint()..style = PaintingStyle.fill;
    const stripesCount = 8;
    final stripeHeight = size.height / stripesCount;
    for (int i = 0; i < stripesCount; i++) {
      if (i % 2 == 0) {
        stripePaint.color = Colors.white.withValues(alpha: 0.045);
        canvas.drawRect(
          Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
          stripePaint,
        );
      }
    }

    // Outer boundary line
    const margin = 12.0;
    final pitchRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - (margin * 2),
      size.height - (margin * 2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pitchRect, const Radius.circular(8)),
      paint,
    );

    // Halfway line
    final midY = size.height / 2;
    canvas.drawLine(
      Offset(margin, midY),
      Offset(size.width - margin, midY),
      paint,
    );

    // Center circle
    final centerCircleRadius = size.width * 0.16;
    canvas.drawCircle(
      Offset(size.width / 2, midY),
      centerCircleRadius,
      paint,
    );

    // Center dot
    final dotPaint = Paint()
      ..color = AppColors.pitchLines
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, midY), 3.5, dotPaint);

    // Penalty box measurements
    final boxWidth = size.width * 0.52;
    final boxHeight = size.height * 0.16;
    final boxLeft = (size.width - boxWidth) / 2;

    // 6-yard box measurements
    final smallBoxWidth = size.width * 0.28;
    final smallBoxHeight = size.height * 0.065;
    final smallBoxLeft = (size.width - smallBoxWidth) / 2;

    // Top penalty box (Opposition)
    canvas.drawRect(
      Rect.fromLTWH(boxLeft, margin, boxWidth, boxHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(smallBoxLeft, margin, smallBoxWidth, smallBoxHeight),
      paint,
    );
    // Top penalty spot
    final topPenaltySpotY = margin + boxHeight * 0.72;
    canvas.drawCircle(Offset(size.width / 2, topPenaltySpotY), 3, dotPaint);

    // Bottom penalty box (Our defense / GK)
    final bottomBoxTop = size.height - margin - boxHeight;
    canvas.drawRect(
      Rect.fromLTWH(boxLeft, bottomBoxTop, boxWidth, boxHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        smallBoxLeft,
        size.height - margin - smallBoxHeight,
        smallBoxWidth,
        smallBoxHeight,
      ),
      paint,
    );
    // Bottom penalty spot
    final bottomPenaltySpotY = size.height - margin - (boxHeight * 0.72);
    canvas.drawCircle(Offset(size.width / 2, bottomPenaltySpotY), 3, dotPaint);

    // Corner arcs (10px radius)
    const cornerRadius = 12.0;
    // Top-left
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(margin, margin), radius: cornerRadius),
      0,
      1.5708,
      false,
      paint,
    );
    // Top-right
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - margin, margin), radius: cornerRadius),
      1.5708,
      1.5708,
      false,
      paint,
    );
    // Bottom-right
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width - margin, size.height - margin), radius: cornerRadius),
      3.14159,
      1.5708,
      false,
      paint,
    );
    // Bottom-left
    canvas.drawArc(
      Rect.fromCircle(center: Offset(margin, size.height - margin), radius: cornerRadius),
      4.71239,
      1.5708,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
