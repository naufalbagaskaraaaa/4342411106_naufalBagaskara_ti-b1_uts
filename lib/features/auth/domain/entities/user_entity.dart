/// User entity representing a user in the domain layer
class UserEntity {
  final String id;
  final String email;
  final String nama;
  final String role;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated fields
  UserEntity copyWith({
    String? id,
    String? email,
    String? nama,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user has specific role
  bool hasRole(String requiredRole) {
    return role == requiredRole;
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is helpdesk
  bool get isHelpdesk => role == 'helpdesk';

  /// Check if user is regular user
  bool get isUser => role == 'user';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.nama == nama &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        nama.hashCode ^
        role.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, nama: $nama, role: $role, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
