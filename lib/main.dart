import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/env/env_config.dart';
import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_coach/presentation/ai_scout_screen.dart';
import 'features/community/presentation/community_tactics_screen.dart';
import 'features/players/presentation/player_list_screen.dart';
import 'features/squad/presentation/saved_squads_screen.dart';
import 'features/squad/presentation/squad_builder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment configuration (.env)
  await EnvConfig.init();

  // Initialize Supabase if configured
  await SupabaseService.init();

  runApp(
    const ProviderScope(
      child: EFootyTacticsApp(),
    ),
  );
}

class EFootyTacticsApp extends StatelessWidget {
  const EFootyTacticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eFootyTactics AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  final List<Widget> _screens = const [
    SquadBuilderScreen(),
    PlayerListScreen(),
    AIScoutScreen(),
    CommunityTacticsScreen(),
    SavedSquadsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.cardBorder.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer_outlined),
              activeIcon: Icon(Icons.sports_soccer),
              label: 'Squad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt),
              label: 'Database',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'AI Scout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hub_outlined),
              activeIcon: Icon(Icons.hub),
              label: 'Komunitas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: 'Koleksi',
            ),
          ],
        ),
      ),
    );
  }
}
