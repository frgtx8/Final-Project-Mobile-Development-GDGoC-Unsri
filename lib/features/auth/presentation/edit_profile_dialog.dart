import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/clubs.dart';
import '../../../core/constants/playstyles.dart';
import 'auth_provider.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const EditProfileDialog(),
    );
  }

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _usernameController;
  late String _selectedClub;
  late String _selectedPlaystyle;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _usernameController =
        TextEditingController(text: user?.username ?? 'Manager');

    final club = user?.favoriteClub ?? 'Real Madrid';
    _selectedClub = Clubs.popularClubs.contains(club)
        ? club
        : Clubs.popularClubs.first;

    final playstyle = user?.favoritePlaystyle ?? Playstyles.quickCounter;
    _selectedPlaystyle = Playstyles.allTeamPlaystyles.contains(playstyle)
        ? playstyle
        : Playstyles.quickCounter;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username Manager tidak boleh kosong.'),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final success = await ref.read(authControllerProvider.notifier).updateProfile(
          username: username,
          favoriteClub: _selectedClub,
          favoritePlaystyle: _selectedPlaystyle,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil Manager berhasil diperbarui!'),
          backgroundColor: AppColors.accentGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final error = ref.read(authControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal memperbarui profil.'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      title: const Row(
        children: [
          Icon(Icons.manage_accounts, color: AppColors.primaryNeon),
          SizedBox(width: 10),
          Text(
            'Edit Profil Manager',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username field
            const Text(
              'Username Manager',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person,
                    color: AppColors.primaryNeon, size: 20),
                hintText: 'Nama panggilan manager...',
                fillColor: AppColors.surfaceLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Favorite Club dropdown
            const Text(
              'Klub Favorit',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedClub,
              dropdownColor: AppColors.surfaceLight,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.shield,
                    color: AppColors.accentGold, size: 20),
                fillColor: AppColors.surfaceLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
              items: Clubs.popularClubs.map((club) {
                return DropdownMenuItem<String>(
                  value: club,
                  child: Text(club),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedClub = val);
              },
            ),
            const SizedBox(height: 16),

            // Favorite Playstyle dropdown
            const Text(
              'Gaya Main Utama',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedPlaystyle,
              dropdownColor: AppColors.surfaceLight,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.auto_awesome,
                    color: AppColors.primaryNeon, size: 20),
                fillColor: AppColors.surfaceLight,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
              items: Playstyles.allTeamPlaystyles.map((style) {
                return DropdownMenuItem<String>(
                  value: style,
                  child: Text(style),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPlaystyle = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNeon,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text('Simpan Perubahan'),
        ),
      ],
    );
  }
}
