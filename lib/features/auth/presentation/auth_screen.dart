import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
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
  final String _favoriteClub = 'Real Madrid';

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
        favoriteClub: _favoriteClub,
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
            // Branding Icon
            const Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.surfaceLight,
                child: Icon(
                  Icons.sports_soccer,
                  size: 40,
                  color: AppColors.primaryNeon,
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
