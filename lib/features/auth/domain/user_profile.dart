import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String favoriteClub;
  final String favoritePlaystyle;
  final String? avatarUrl;
  final bool isGuest;
  final String role; // 'admin' or 'user'

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.favoriteClub = 'Real Madrid',
    this.favoritePlaystyle = 'Quick Counter',
    this.avatarUrl,
    this.isGuest = false,
    this.role = 'user',
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserProfile.guest({bool asAdmin = false}) {
    return UserProfile(
      id: asAdmin ? 'guest-admin-id' : 'guest-user-id',
      username: asAdmin ? 'Admin eFooty' : 'Manager Solo',
      email: asAdmin ? 'admin@efooty.local' : 'manager@efooty.local',
      favoriteClub: 'Arsenal',
      favoritePlaystyle: 'Quick Counter',
      isGuest: true,
      role: asAdmin ? 'admin' : 'user',
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json, {String email = ''}) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Manager',
      email: email,
      favoriteClub: json['favorite_club'] as String? ?? 'Real Madrid',
      favoritePlaystyle:
          json['favorite_playstyle'] as String? ?? 'Quick Counter',
      avatarUrl: json['avatar_url'] as String?,
      isGuest: false,
      role: json['role'] as String? ?? (email.contains('admin') ? 'admin' : 'user'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'favorite_club': favoriteClub,
        'favorite_playstyle': favoritePlaystyle,
        'avatar_url': avatarUrl,
        'role': role,
      };

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? favoriteClub,
    String? favoritePlaystyle,
    String? avatarUrl,
    bool? isGuest,
    String? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      favoriteClub: favoriteClub ?? this.favoriteClub,
      favoritePlaystyle: favoritePlaystyle ?? this.favoritePlaystyle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
      role: role ?? this.role,
    );
  }
}
