import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/formation_repository.dart';

final formationRepositoryProvider = Provider<FormationRepository>((ref) {
  return FormationRepository();
});

final availableFormationsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(formationRepositoryProvider);
  return await repo.loadFormations();
});
