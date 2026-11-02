import 'package:equatable/equatable.dart';

/// Who a role's users work for.
enum RoleOrganization {
  /// HASEEN staff.
  haseen,

  /// The client facility's own staff.
  facility,
}

/// A role in the system and how many users hold it.
class SystemRole extends Equatable {
  final String name;
  final int usersCount;
  final RoleOrganization organization;

  const SystemRole({
    required this.name,
    required this.usersCount,
    required this.organization,
  });

  @override
  List<Object> get props => [name, usersCount, organization];
}
