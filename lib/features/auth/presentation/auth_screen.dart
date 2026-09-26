import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/clubs.dart';
import '../../../core/constants/playstyles.dart';
import 'auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _adminCodeController = TextEditingController();
  String _selectedPlaystyle = Playstyles.quickCounter;
  String _selectedClub = 'Real Madrid';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  void _showErrorPopup(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(milliseconds: 3500),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isSignUp && _usernameController.text.trim().isEmpty) {
      _showErrorPopup('Username Manager wajib diisi.');
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      _showErrorPopup('Email dan password tidak boleh kosong.');
      return;
    }

    if (password.length < 6) {
      _showErrorPopup('Password minimal harus 6 karakter.');
      return;
    }

    if (_isSignUp) {
      final confirmPassword = _confirmPasswordController.text.trim();
      if (confirmPassword.isEmpty) {
        _showErrorPopup('Harap ulangi password pada kolom Konfirmasi Password.');
        return;
      }
      if (password != confirmPassword) {
        _showErrorPopup('Password dan Konfirmasi Password tidak cocok!');
        return;
      }
    }

    final auth = ref.read(authControllerProvider.notifier);
    bool success;

    if (_isSignUp) {
      final username = _usernameController.text.trim();

      success = await auth.signUpWithEmail(
        email: email,
        password: password,
        username: username,
        favoriteClub: _selectedClub,
        favoritePlaystyle: _selectedPlaystyle,
        role: 'user',
      );
    } else {
      success = await auth.signInWithEmail(email, password);
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSignUp
                ? 'Akun Manager berhasil didaftarkan!'
                : 'Berhasil masuk sebagai ${_emailController.text.trim()}',
          ),
          backgroundColor: AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_reset, color: AppColors.primaryNeon),
              SizedBox(width: 10),
              Text(
                'Lupa Password?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan email akun eFootball Anda. Kami akan mengirimkan tautan untuk mengatur ulang password baru.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Alamat Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNeon,
                foregroundColor: Colors.black,
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Alamat email wajib diisi.'),
                            backgroundColor: AppColors.accentRed,
                          ),
                        );
                        return;
                      }

                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(dialogCtx);

                      setDialogState(() => isSending = true);
                      final ok = await ref
                          .read(authControllerProvider.notifier)
                          .sendPasswordResetEmail(email);

                      if (!mounted) return;
                      setDialogState(() => isSending = false);

                      if (ok) {
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tautan reset password berhasil dikirim ke $email! Silakan cek kotak masuk atau spam.',
                            ),
                            backgroundColor: AppColors.accentGreen,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      } else {
                        final err =
                            ref.read(authControllerProvider).errorMessage;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(err ??
                                'Gagal mengirim email reset password.'),
                            backgroundColor: AppColors.accentRed,
                          ),
                        );
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Kirim Tautan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Otomatis tampilkan Pop Up error yang bisa hilang saat ada error dari controller
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showErrorPopup(next.errorMessage!);
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'DAFTAR AKUN eFOOTBALL' : 'LOGIN SUPABASE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Branding Logo
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNeon.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const CircleAvatar(
                      backgroundColor: AppColors.surfaceLight,
                      child: Icon(
                        Icons.sports_soccer,
                        size: 40,
                        color: AppColors.primaryNeon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _isSignUp ? 'Buat Akun Manager Baru' : 'Masuk dengan Akun Anda',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _isSignUp
                    ? 'Daftar untuk menyimpan & mensinkronkan taktik ke Cloud'
                    : 'Gunakan Email dan Password terdaftar Anda',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            if (_isSignUp) ...[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username Manager',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Password Requirement & Strength Helper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    _passwordController.text.length >= 6
                        ? Icons.check_circle
                        : (_passwordController.text.isEmpty
                            ? Icons.info_outline
                            : Icons.cancel_outlined),
                    size: 14,
                    color: _passwordController.text.length >= 6
                        ? AppColors.accentGreen
                        : (_passwordController.text.isEmpty
                            ? AppColors.textMuted
                            : AppColors.accentRed),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _passwordController.text.isEmpty
                        ? 'Minimal 6 karakter'
                        : (_passwordController.text.length < 6
                            ? 'Minimal 6 karakter (${_passwordController.text.length}/6)'
                            : 'Password memenuhi syarat (min. 6 karakter)'),
                    style: TextStyle(
                      color: _passwordController.text.length >= 6
                          ? AppColors.accentGreen
                          : (_passwordController.text.isEmpty
                              ? AppColors.textMuted
                              : AppColors.accentRed),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (!_isSignUp) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: AppColors.primaryNeon,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            if (_isSignUp) ...[
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Ulangi / Konfirmasi Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (_isSignUp) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedClub,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Klub Favorit',
                  prefixIcon: Icon(Icons.shield_outlined),
                ),
                dropdownColor: AppColors.surface,
                items: Clubs.popularClubs.map((club) {
                  return DropdownMenuItem(value: club, child: Text(club));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedClub = val);
                },
              ),
              const SizedBox(height: 12),
            ],

            if (_isSignUp) ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedPlaystyle,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Gaya Main Favorit',
                  prefixIcon: Icon(Icons.tune),
                ),
                dropdownColor: AppColors.surface,
                items: Playstyles.allTeamPlaystyles.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPlaystyle = val);
                },
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _handleSubmit,
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isSignUp ? 'DAFTAR SEKARANG' : 'MASUK KE AKUN'),
            ),
            const SizedBox(height: 14),

            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(
                _isSignUp
                    ? 'Sudah punya akun? Masuk di sini'
                    : 'Belum punya akun? Buat akun sekarang',
                style: const TextStyle(color: AppColors.primaryNeon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
