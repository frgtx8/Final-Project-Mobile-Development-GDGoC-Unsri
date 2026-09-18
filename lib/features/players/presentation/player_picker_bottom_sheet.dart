import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../squad/presentation/squad_controller.dart';
import '../domain/player.dart';
import 'player_card_widget.dart';
import 'players_provider.dart';

class PlayerPickerBottomSheet extends ConsumerStatefulWidget {
  final String slotId;
  final String defaultPosition;
  final Function(Player selectedPlayer) onPlayerSelected;

  const PlayerPickerBottomSheet({
    super.key,
    required this.slotId,
    required this.defaultPosition,
    required this.onPlayerSelected,
  });

  static void show(
    BuildContext context, {
    required String slotId,
    required String defaultPosition,
    required Function(Player) onPlayerSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PlayerPickerBottomSheet(
        slotId: slotId,
        defaultPosition: defaultPosition,
        onPlayerSelected: onPlayerSelected,
      ),
    );
  }

  @override
  ConsumerState<PlayerPickerBottomSheet> createState() =>
      _PlayerPickerBottomSheetState();
}

class _PlayerPickerBottomSheetState
    extends ConsumerState<PlayerPickerBottomSheet> {
  String _searchQuery = '';
  bool _filterByPosition = true;
  bool _filterOnlyAvailable = false;

  @override
  Widget build(BuildContext context) {
    final allPlayersAsync = ref.watch(allPlayersProvider);
    final currentSquad = ref.watch(currentSquadProvider);
    final startingEleven = currentSquad.startingEleven;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag Indicator
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 14),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNeon.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryNeon,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          widget.slotId,
                          style: const TextStyle(
                            color: AppColors.primaryNeon,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Pemain Formasi',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rekomendasi Posisi: ${widget.defaultPosition}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search field
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari pemain, klub, atau posisi...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(
                        'Cocok ${widget.defaultPosition}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _filterByPosition
                              ? Colors.black
                              : AppColors.textSecondary,
                        ),
                      ),
                      selected: _filterByPosition,
                      backgroundColor: AppColors.surfaceLight,
                      selectedColor: AppColors.primaryNeon,
                      checkmarkColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _filterByPosition
                              ? AppColors.primaryNeon
                              : AppColors.cardBorder,
                        ),
                      ),
                      onSelected: (val) {
                        setState(() {
                          _filterByPosition = val;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        'Belum Dipakai',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _filterOnlyAvailable
                              ? Colors.black
                              : AppColors.textSecondary,
                        ),
                      ),
                      selected: _filterOnlyAvailable,
                      backgroundColor: AppColors.surfaceLight,
                      selectedColor: AppColors.accentGreen,
                      checkmarkColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _filterOnlyAvailable
                              ? AppColors.accentGreen
                              : AppColors.cardBorder,
                        ),
                      ),
                      onSelected: (val) {
                        setState(() {
                          _filterOnlyAvailable = val;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        'Semua Pemain',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: (!_filterByPosition && !_filterOnlyAvailable)
                              ? AppColors.primaryNeon
                              : AppColors.textSecondary,
                        ),
                      ),
                      selected: !_filterByPosition && !_filterOnlyAvailable,
                      backgroundColor: AppColors.surfaceLight,
                      selectedColor:
                          AppColors.primaryNeon.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: (!_filterByPosition && !_filterOnlyAvailable)
                              ? AppColors.primaryNeon
                              : AppColors.cardBorder,
                        ),
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _filterByPosition = false;
                            _filterOnlyAvailable = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Players list
              Expanded(
                child: allPlayersAsync.when(
                  data: (players) {
                    final filtered = players.where((p) {
                      final matchQuery = _searchQuery.isEmpty ||
                          p.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          p.club
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          p.primaryPosition
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          p.secondaryPositions.any((pos) => pos
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()));

                      final matchPos = !_filterByPosition ||
                          p.canPlayPosition(widget.defaultPosition);

                      final isAssigned = startingEleven.containsValue(p.id);
                      final matchAvailable =
                          !_filterOnlyAvailable || !isAssigned;

                      return matchQuery && matchPos && matchAvailable;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tidak ada pemain yang cocok.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _filterByPosition = false;
                                  _filterOnlyAvailable = false;
                                  _searchQuery = '';
                                });
                              },
                              child: const Text('Reset Filter'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        final player = filtered[index];
                        final isCurrentSlot =
                            startingEleven[widget.slotId] == player.id;
                        final assignedSlot = startingEleven.entries
                            .cast<MapEntry<String, String>?>()
                            .firstWhere((e) => e?.value == player.id,
                                orElse: () => null)
                            ?.key;

                        final effectiveOvr =
                            player.getEffectiveRating(widget.defaultPosition);

                        Widget trailingButton;
                        if (isCurrentSlot) {
                          trailingButton = OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.accentGreen, width: 1.2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check,
                                    size: 14, color: AppColors.accentGreen),
                                SizedBox(width: 4),
                                Text(
                                  'Aktif',
                                  style: TextStyle(
                                    color: AppColors.accentGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (assignedSlot != null) {
                          trailingButton = ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              widget.onPlayerSelected(player);
                              Navigator.pop(context);
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.swap_horiz,
                                    size: 14, color: Colors.black),
                                SizedBox(width: 4),
                                Text(
                                  'Pindahkan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          trailingButton = ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNeon,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              widget.onPlayerSelected(player);
                              Navigator.pop(context);
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 14, color: Colors.black),
                                SizedBox(width: 4),
                                Text(
                                  'Pasang',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PlayerCardWidget(
                            player: player,
                            isCompact: true,
                            isCurrentSlot: isCurrentSlot,
                            assignedSlot: isCurrentSlot ? null : assignedSlot,
                            effectiveOvr: effectiveOvr,
                            trailing: trailingButton,
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: AppColors.accentRed),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
