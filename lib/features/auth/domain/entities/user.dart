import 'package:equatable/equatable.dart';

/// Role pengguna dalam sistem MIS.
enum UserRole {
  director('Director'),
  finance('Finance'),
  sales('Sales'),
  projectManager('Project Manager'),
  production('Production');

  const UserRole(this.label);
  final String label;
}

/// Model data user.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;

  /// Inisial untuk avatar fallback (2 huruf pertama).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.production,
      ),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'avatar_url': avatarUrl,
      };

  @override
  List<Object?> get props => [id, name, email, role, avatarUrl];
}
