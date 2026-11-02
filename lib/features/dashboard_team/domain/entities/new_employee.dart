import 'package:equatable/equatable.dart';

import 'employee_role.dart';
import 'team_member.dart';

/// An employee to invite: they set their password from the invitation link.
class NewEmployee extends Equatable {
  final String fullName;
  final String email;

  /// Optional; empty when not given.
  final String phone;
  final EmployeeRole role;

  const NewEmployee({
    required this.fullName,
    required this.email,
    this.phone = '',
    required this.role,
  });

  /// The roster name: field staff get the engineer title.
  String get displayName => role.isFieldRole
      ? '${TeamMember.engineerPrefix}${fullName.trim()}'
      : fullName.trim();

  bool get isComplete => fullName.trim().isNotEmpty && email.trim().isNotEmpty;

  @override
  List<Object> get props => [fullName, email, phone, role];
}
