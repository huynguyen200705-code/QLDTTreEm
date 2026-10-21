import 'dart:convert';

enum UserRole {
  admin,
  staff,
  parent,
  kid,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Quản trị viên (Admin)';
      case UserRole.staff:
        return 'Nhân viên hỗ trợ (Staff)';
      case UserRole.parent:
        return 'Phụ huynh (Parent)';
      case UserRole.kid:
        return 'Trẻ em (Kid Device)';
    }
  }

  String get keyName => name;

  static UserRole fromString(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
      case 'employee':
        return UserRole.staff;
      case 'kid':
      case 'child':
        return UserRole.kid;
      case 'parent':
      default:
        return UserRole.parent;
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String username;
  final String phoneNumber;
  final UserRole role;
  final String avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final String? linkedChildId; // Dành cho vai trò Kid liên kết với cha mẹ

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    required this.phoneNumber,
    required this.role,
    this.avatarUrl = '',
    this.isActive = true,
    DateTime? createdAt,
    this.linkedChildId,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? phoneNumber,
    UserRole? role,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    String? linkedChildId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      linkedChildId: linkedChildId ?? this.linkedChildId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'username': username,
      'phoneNumber': phoneNumber,
      'role': role.keyName,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'linkedChildId': linkedChildId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: UserRoleExtension.fromString(map['role']),
      avatarUrl: map['avatarUrl'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      linkedChildId: map['linkedChildId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}
