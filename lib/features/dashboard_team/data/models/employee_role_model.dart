import '../../domain/entities/employee_role.dart';

/// A document of the Firestore `roles` collection: the document id is the
/// role code; `name`, `description`, `field` (works in the field app) and
/// `order` (position in the picker).
class EmployeeRoleModel {
  final String id;
  final String name;
  final String description;
  final bool isFieldRole;
  final int order;

  const EmployeeRoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isFieldRole,
    this.order = 0,
  });

  /// Missing fields read safely: no description, not a field role, order 0.
  factory EmployeeRoleModel.fromDocument(
    String id,
    Map<String, Object?> json,
  ) => EmployeeRoleModel(
    id: id,
    name: json['name'] as String? ?? id,
    description: json['description'] as String? ?? '',
    isFieldRole: json['field'] as bool? ?? false,
    order: (json['order'] as num?)?.toInt() ?? 0,
  );

  EmployeeRole toEntity() => EmployeeRole(
    id: id,
    name: name,
    description: description,
    isFieldRole: isFieldRole,
  );
}
