import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

/// Data transfer object for User entity.
/// Used for data mapping between Supabase and domain layer.
class UserModel {
  final String id;
  final String email;
  final String nama;
  final String role;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from Supabase User response
  factory UserModel.fromSupabase(User user) {
    final userMetadata = user.userMetadata ?? {};
    final DateTime createdAt = DateTime.parse(user.createdAt.toString());

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      nama: userMetadata['nama']?.toString() ?? '',
      role: userMetadata['role']?.toString() ?? 'user',
      createdAt: createdAt,
      updatedAt: userMetadata['updated_at'] != null
          ? DateTime.tryParse(userMetadata['updated_at'].toString())
          : null,
    );
  }

  /// Create UserModel from database record (Map)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nama: json['nama'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to database JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      nama: nama,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create UserModel from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      nama: entity.nama,
      role: entity.role,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
