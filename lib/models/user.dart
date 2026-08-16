import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { utilisateur, organisateur, admin }

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final roleValue = json['role'];

    // Accept both French and legacy English role names (backward compatible)
    UserRole role;
    if (roleValue is String) {
      if (roleValue == 'organisateur' || roleValue == 'organizer') {
        role = UserRole.organisateur;
      } else if (roleValue == 'admin') {
        role = UserRole.admin;
      } else {
        // 'utilisateur', 'user', or anything else
        role = UserRole.utilisateur;
      }
    } else {
      role = UserRole.utilisateur;
    }

    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseOptionalDate(dynamic date) {
      if (date == null) return null;
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Utilisateur',
      role: role,
      phone: json['phone']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseOptionalDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': roleToString(role),
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.organisateur:
        return 'organisateur';
      case UserRole.utilisateur:
        return 'utilisateur';
    }
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
