import 'package:equatable/equatable.dart';

/// The signed-in employee: their account plus the profile stored for them.
class AuthUser extends Equatable {
  /// The only role allowed into the dashboard.
  static const adminRole = 'admin';

  final String id;
  final String email;
  final String displayName;
  final String role;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  bool get isAdmin => role == adminRole;

  @override
  List<Object?> get props => [id, email, displayName, role];
}
