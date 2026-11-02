import '../../domain/entities/auth_user.dart';

/// A Firebase account joined with its document in the `users` collection
/// (`email`, `name`, `role`).
class AuthUserModel {
  final String id;
  final String email;
  final String name;
  final String role;

  const AuthUserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  /// [accountEmail] fills in when the profile has no `email`; missing
  /// `name`/`role` read as empty, so such a profile is never an admin.
  factory AuthUserModel.fromProfile({
    required String id,
    required String accountEmail,
    required Map<String, Object?> json,
  }) => AuthUserModel(
    id: id,
    email: json['email'] as String? ?? accountEmail,
    name: json['name'] as String? ?? '',
    role: (json['role'] as String? ?? '').trim(),
  );

  AuthUser toEntity() =>
      AuthUser(id: id, email: email, displayName: name, role: role);
}
