import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/employee_role.dart';
import '../entities/new_employee.dart';
import '../entities/team_member.dart';

abstract interface class TeamRepository {
  Future<Either<Failure, List<TeamMember>>> getTeamMembers();

  Future<Either<Failure, List<EmployeeRole>>> getEmployeeRoles();

  /// Creates the employee's account with [temporaryPassword], stores their
  /// profile (pending activation) and returns the new member.
  Future<Either<Failure, TeamMember>> addEmployee(
    NewEmployee employee, {
    required String temporaryPassword,
  });
}
