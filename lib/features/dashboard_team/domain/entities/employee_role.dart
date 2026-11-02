import 'package:equatable/equatable.dart';

/// A job a new employee can be given.
class EmployeeRole extends Equatable {
  /// Stable code stored with the account (e.g. `inspector`); never `admin`,
  /// so no role picked here can open the dashboard.
  final String id;
  final String name;
  final String description;

  /// Works in the field app; field staff carry the engineer title.
  final bool isFieldRole;

  const EmployeeRole({
    required this.id,
    required this.name,
    required this.description,
    required this.isFieldRole,
  });

  @override
  List<Object> get props => [id, name, description, isFieldRole];
}
