import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/formations.dart';
import 'formations_provider.dart';
import 'squad_controller.dart';

class AdminAddFormationDialog extends ConsumerStatefulWidget {
  const AdminAddFormationDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AdminAddFormationDialog(),
    );
  }

  @override
  ConsumerState<AdminAddFormationDialog> createState() =>
      _AdminAddFormationDialogState();
}

class _AdminAddFormationDialogState
    extends ConsumerState<AdminAddFormationDialog> {
  final _idController = TextEditingController(text: '4-3-1-2');
  final _nameController =
      TextEditingController(text: '4-3-1-2 (Narrow Diamond)');
  String _baseTemplate = Formations.f433;
  bool _isSaving = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Formasi wajib diisi (contoh: 4-3-1-2)'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Derive slots from base template or custom diamond layout
    List<PitchSlot> slots;
    if (id == '4-3-1-2') {
      slots = const [
        PitchSlot(id: 'GK', defaultPosition: 'GK', x: 0.50, y: 0.90),
        PitchSlot(id: 'LB', defaultPosition: 'LB', x: 0.15, y: 0.74),
        PitchSlot(id: 'CB1', defaultPosition: 'CB', x: 0.38, y: 0.77),
        PitchSlot(id: 'CB2', defaultPosition: 'CB', x: 0.62, y: 0.77),
        PitchSlot(id: 'RB', defaultPosition: 'RB', x: 0.85, y: 0.74),
        PitchSlot(id: 'DMF', defaultPosition: 'DMF', x: 0.50, y: 0.62),
        PitchSlot(id: 'CMF1', defaultPosition: 'CMF', x: 0.28, y: 0.52),
        PitchSlot(id: 'CMF2', defaultPosition: 'CMF', x: 0.72, y: 0.52),
        PitchSlot(id: 'AMF', defaultPosition: 'AMF', x: 0.50, y: 0.38),
        PitchSlot(id: 'CF1', defaultPosition: 'CF', x: 0.38, y: 0.18),
        PitchSlot(id: 'CF2', defaultPosition: 'CF', x: 0.62, y: 0.18),
      ];
    } else {
      slots = Formations.getSlots(_baseTemplate);
    }

    try {
      final savedToCloud =
          await ref.read(formationRepositoryProvider).addCustomFormation(
                id: id,
                name: name.isEmpty ? id : name,
                slots: slots,
              );

      ref.invalidate(availableFormationsProvider);
      ref.read(currentSquadProvider.notifier).setFormation(id);

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              savedToCloud
                  ? 'Formasi "$id" berhasil disimpan ke Supabase Cloud (Tersinkron ke semua user)!'
                  : 'Formasi "$id" tersimpan di memori lokal.',
            ),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan formasi ke Cloud ($e).'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: const [
                  Icon(Icons.sports, color: AppColors.accentGold),
                  SizedBox(width: 8),
                  Text(
                    'TAMBAH FORMASI CLOUD',
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Sebagai Admin, formasi yang Anda tambahkan akan otomatis tersimpan di Supabase dan dapat digunakan oleh semua user.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Kode Formasi (contoh: 4-3-1-2)',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama / Deskripsi Taktik',
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _baseTemplate,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  labelText: 'Basis Layout Lapangan',
                  prefixIcon: Icon(Icons.grid_view),
                ),
                items: Formations.defaultFormations.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(
                      f,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _baseTemplate = val);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _isSaving ? null : _handleSave,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: const Text(
                      'Simpan Formasi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
