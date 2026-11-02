import '../../domain/entities/system_role.dart';

/// A role as JSON: `name`, `users` (count) and `organization` (haseen /
/// facility).
class SystemRoleModel {
  final String name;
  final int usersCount;
  final RoleOrganization organization;

  const SystemRoleModel({
    required this.name,
    required this.usersCount,
    required this.organization,
  });

  /// Throws on a malformed payload, a negative count or an unknown
  /// organization.
  factory SystemRoleModel.fromJson(Map<String, Object?> json) {
    final model = SystemRoleModel(
      name: json['name']! as String,
      usersCount: json['users']! as int,
      organization:
          _organizationByCode[json['organization']] ??
          (throw FormatException(
            'Unknown organization: ${json['organization']}',
          )),
    );
    if (model.usersCount < 0) {
      throw FormatException('Role ${model.name} has a negative user count.');
    }
    return model;
  }

  static const _organizationByCode = {
    'haseen': RoleOrganization.haseen,
    'facility': RoleOrganization.facility,
  };

  SystemRole toEntity() => SystemRole(
    name: name,
    usersCount: usersCount,
    organization: organization,
  );
}
