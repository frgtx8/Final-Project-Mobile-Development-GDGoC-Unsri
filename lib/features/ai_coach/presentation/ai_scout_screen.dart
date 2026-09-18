import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../squad/presentation/squad_controller.dart';
import 'ai_coach_provider.dart';

class AIScoutScreen extends ConsumerStatefulWidget {
  const AIScoutScreen({super.key});

  @override
  ConsumerState<AIScoutScreen> createState() => _AIScoutScreenState();
}

class _AIScoutScreenState extends ConsumerState<AIScoutScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    '3 pemain pemburu celah (Hole Player) terbaik',
    '3 striker pemburu gol (Goal Poacher) paling tajam',
    'Rekomendasi gelandang jangkar (Anchor Man) penyeimbang',
    'CB Build Up cepat untuk garis pertahanan tinggi',
    'Winger sayap lincah (Roaming Flank) skill Double Touch',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitQuery(String query) {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    _queryController.text = query;
    ref.read(aiScoutControllerProvider.notifier).askScout(query);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final scoutState = ref.watch(aiScoutControllerProvider);
    final squad = ref.watch(currentSquadProvider);

    // Auto-scroll when response arrives
    ref.listen(aiScoutControllerProvider, (prev, next) {
      if (next.responseText != null && prev?.responseText != next.responseText) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI PLAYER SCOUT & BUILDS'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Playstyle Info Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceLight,
            child: Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primaryNeon, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Fokus Taktik Tim: ${squad.teamPlaystyle}',
                  style: const TextStyle(
                    color: AppColors.primaryNeon,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Topik Cepat (Quick Prompts):',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickPrompts.map((prompt) {
                      return ActionChip(
                        label: Text(
                          prompt,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.cardBorder),
                        onPressed: scoutState.isLoading
                            ? null
                            : () => _submitQuery(prompt),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // AI Response Card
                  if (scoutState.isLoading) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'AI Scout sedang meracik rekomendasi pemain & poin latihan...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (scoutState.responseText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primaryNeon.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.smart_toy,
                                  color: AppColors.primaryNeon, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Rekomendasi AI Scout eFootball',
                                style: TextStyle(
                                  color: AppColors.primaryNeon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                              color: AppColors.cardBorder, height: 20),
                          SelectableText(
                            scoutState.responseText!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60), // Ample bottom runway so entire text can be comfortably scrolled
                  ] else ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.person_search_outlined,
                                size: 56,
                                color: AppColors.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text(
                              'Tanyakan pemain apa pun yang ingin Anda cari atau konsultasikan alokasi poin latihan.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pemain idaman atau tanya taktik...',
                      isDense: true,
                    ),
                    onSubmitted: (val) => _submitQuery(val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryNeon,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.send, size: 18),
                  onPressed: scoutState.isLoading
                      ? null
                      : () => _submitQuery(_queryController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
