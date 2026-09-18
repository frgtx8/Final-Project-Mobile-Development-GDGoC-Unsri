import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/user_profile.dart';

class AuthRepository {
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool _isAdminEmail(String? email) {
    if (email == null) return false;
    final e = email.toLowerCase().trim();
    return e == 'rahmanfadil274@gmai.com' ||
        e == 'rahmanfadil274@gmail.com' ||
        e == 'admin@efooty.com';
  }

  Future<UserProfile?> checkSession() async {
    // 1. If Supabase is connected, check current auth user
    if (SupabaseService.isInitialized) {
      final client = SupabaseService.client;
      final session = client?.auth.currentSession;
      if (session != null && client != null) {
        try {
          final profileRes = await client
              .from('profiles')
              .select()
              .eq('id', session.user.id)
              .maybeSingle();

          if (profileRes != null) {
            _currentUser = UserProfile.fromJson(
              profileRes,
              email: session.user.email ?? '',
            );
            if (_isAdminEmail(session.user.email) || profileRes['role'] == 'admin') {
              _currentUser = _currentUser!.copyWith(role: 'admin');
            }
            return _currentUser;
          }
        } catch (_) {}
      }
    }

    // 2. Check local shared preferences for saved guest session
    final prefs = await SharedPreferences.getInstance();
    final isGuestLoggedIn = prefs.getBool('is_guest_logged_in') ?? false;
    final isAdmin = prefs.getBool('is_admin_mode') ?? false;
    if (isGuestLoggedIn) {
      _currentUser = UserProfile.guest(asAdmin: isAdmin);
      return _currentUser;
    }

    return null;
  }

  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!SupabaseService.isInitialized) {
      throw Exception(
        'Supabase belum terhubung. Periksa konfigurasi .env Anda',
      );
    }

    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Email dan password wajib diisi.');
    }

    final client = SupabaseService.client!;
    try {
      final response = await client.auth.signInWithPassword(
        email: trimmedEmail,
        password: trimmedPassword,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Email atau password salah.');
      }

      final profileRes = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      final isAdmin = _isAdminEmail(trimmedEmail) || profileRes?['role'] == 'admin';
      if (profileRes != null) {
        _currentUser = UserProfile.fromJson(
          profileRes,
          email: user.email ?? trimmedEmail,
        );
        if (isAdmin) {
          _currentUser = _currentUser!.copyWith(role: 'admin');
        }
      } else {
        _currentUser = UserProfile(
          id: user.id,
          username: user.email?.split('@').first ?? 'Manager',
          email: user.email ?? trimmedEmail,
          role: isAdmin ? 'admin' : 'user',
        );
      }

      return _currentUser!;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('invalid login credentials') ||
          errStr.contains('invalid_grant') ||
          errStr.contains('user not found')) {
        throw Exception('Email atau password salah.');
      } else if (errStr.contains('email not confirmed')) {
        throw Exception('Email belum terkonfirmasi. Periksa kotak masuk email Anda.');
      } else if (errStr.contains('network') ||
          errStr.contains('socket') ||
          errStr.contains('timeout')) {
        throw Exception('Koneksi internet bermasalah. Periksa koneksi Anda.');
      }
      // Strip out raw exception tags if any
      final cleanMsg = e.toString().replaceAll('Exception: ', '').trim();
      throw Exception(cleanMsg.isNotEmpty ? cleanMsg : 'Gagal masuk. Periksa kembali akun Anda.');
    }
  }

  Future<UserProfile> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String favoriteClub = 'Real Madrid',
    String favoritePlaystyle = 'Quick Counter',
    String role = 'user',
  }) async {
    if (!SupabaseService.isInitialized) {
      throw Exception(
        'Supabase belum terhubung. Periksa konfigurasi SUPABASE_URL dan SUPABASE_ANON_KEY di .env',
      );
    }

    final trimmedEmail = email.trim();
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    if (trimmedUsername.isEmpty) {
      throw Exception('Username Manager tidak boleh kosong.');
    }
    if (trimmedEmail.isEmpty) {
      throw Exception('Email tidak boleh kosong.');
    }
    if (trimmedPassword.length < 6) {
      throw Exception('Password minimal harus 6 karakter.');
    }

    final client = SupabaseService.client!;

    // 1. Pre-check: Pastikan username belum digunakan oleh pengguna lain
    try {
      final existingProfile = await client
          .from('profiles')
          .select('id, username')
          .eq('username', trimmedUsername)
          .maybeSingle();

      if (existingProfile != null) {
        throw Exception(
          'Username "$trimmedUsername" sudah digunakan. Silakan pilih username lain.',
        );
      }
    } catch (e) {
      if (e.toString().contains('sudah digunakan')) {
        rethrow;
      }
      // If table check fails due to network or other issue, continue to auth signup
    }

    // 2. Lakukan pendaftaran via Supabase Auth
    try {
      final response = await client.auth.signUp(
        email: trimmedEmail,
        password: trimmedPassword,
        data: {
          'username': trimmedUsername,
          'favorite_club': favoriteClub,
          'favorite_playstyle': favoritePlaystyle,
          'role': role,
        },
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Registrasi gagal. Coba gunakan email lain.');
      }

      // Automatically sign in if session is not immediately returned
      if (response.session == null) {
        try {
          await client.auth.signInWithPassword(
            email: trimmedEmail,
            password: trimmedPassword,
          );
        } catch (_) {}
      }

      _currentUser = UserProfile(
        id: user.id,
        username: trimmedUsername,
        email: trimmedEmail,
        favoriteClub: favoriteClub,
        favoritePlaystyle: favoritePlaystyle,
        role: role,
      );

      return _currentUser!;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('database error saving new user') ||
          errStr.contains('23505') ||
          errStr.contains('profiles_username_key') ||
          errStr.contains('unique constraint')) {
        throw Exception(
          'Username "$trimmedUsername" atau email sudah terdaftar. Silakan gunakan yang lain atau langsung Login.',
        );
      } else if (errStr.contains('user already registered') ||
          errStr.contains('already registered')) {
        throw Exception(
          'Email "$trimmedEmail" sudah terdaftar. Silakan langsung masuk (Login).',
        );
      } else if (errStr.contains('invalid') && errStr.contains('email')) {
        throw Exception('Format email tidak valid. Periksa penulisan email Anda.');
      } else if (errStr.contains('password') &&
          (errStr.contains('short') || errStr.contains('least 6'))) {
        throw Exception('Password minimal harus 6 karakter.');
      } else if (errStr.contains('network') ||
          errStr.contains('socket') ||
          errStr.contains('timeout')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet Anda.');
      }

      final cleanMsg = e.toString().replaceAll('Exception: ', '').trim();
      throw Exception(cleanMsg.isNotEmpty ? cleanMsg : 'Registrasi gagal. Silakan coba beberapa saat lagi.');
    }
  }

  Future<UserProfile> signInAsGuest({
    String username = 'Manager Solo',
    String favoriteClub = 'Arsenal',
    bool asAdmin = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest_logged_in', true);
    await prefs.setBool('is_admin_mode', asAdmin);

    _currentUser = UserProfile.guest(asAdmin: asAdmin);
    return _currentUser!;
  }

  Future<UserProfile> toggleAdminRole() async {
    if (_currentUser == null) {
      return await signInAsGuest(asAdmin: true);
    }
    final newRole = _currentUser!.isAdmin ? 'user' : 'admin';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_admin_mode', newRole == 'admin');

    _currentUser = _currentUser!.copyWith(
      role: newRole,
      username: newRole == 'admin' ? 'Admin eFooty' : 'Manager Solo',
    );
    return _currentUser!;
  }

  Future<void> signOut() async {
    if (SupabaseService.isInitialized) {
      await SupabaseService.client?.auth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_guest_logged_in');
    await prefs.remove('is_admin_mode');
    _currentUser = null;
  }
}
