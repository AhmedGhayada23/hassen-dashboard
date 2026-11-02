import 'package:hassen_dashboard/features/dashboard_team/data/datasources/team_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_team/data/models/employee_role_model.dart';
import 'package:hassen_dashboard/features/dashboard_team/data/models/team_member_model.dart';

import '../fixtures/team_fixture.dart';

/// In-memory stand-in for Firebase: serves the five roles, keeps the
/// employees it creates, or throws [error] when set.
class FakeTeamRemoteDataSource implements TeamRemoteDataSource {
  final employees = <TeamMemberModel>[];
  final created = <Map<String, String>>[];
  List<EmployeeRoleModel> roles = [
    for (final (i, r) in expectedRoles.indexed)
      EmployeeRoleModel(
        id: r.id,
        name: r.name,
        description: r.description,
        isFieldRole: r.isFieldRole,
        order: i,
      ),
  ];
  Object? error;

  @override
  Future<List<TeamMemberModel>> getEmployees() async {
    if (error case final e?) throw e;
    return [...employees];
  }

  @override
  Future<List<EmployeeRoleModel>> getEmployeeRoles() async {
    if (error case final e?) throw e;
    return [...roles];
  }

  @override
  Future<TeamMemberModel> addEmployee({
    required String name,
    required String email,
    required String phone,
    required String roleId,
    required String roleName,
    required String temporaryPassword,
  }) async {
    if (error case final e?) throw e;
    created.add({
      'name': name,
      'email': email,
      'phone': phone,
      'role': roleId,
      'role_name': roleName,
      'temporary_password': temporaryPassword,
    });
    final member =
        TeamMemberModel.fromUserDocument('uid-${employees.length + 1}', {
          'name': name,
          'role_name': roleName,
          'pending_activation': true,
          'temporary_password': temporaryPassword,
        });
    employees.add(member);
    return member;
  }
}
