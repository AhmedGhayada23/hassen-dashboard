import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/employee_role.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/new_employee.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/team_member.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/repositories/team_repository.dart';

import '../fixtures/team_fixture.dart';

/// Repository stub over the original roster. [addEmployee] records [added]
/// (and the temporary password it was given) and answers a pending member,
/// or [addFailure] when set.
class FakeTeamRepository implements TeamRepository {
  List<TeamMember> members = [...expectedTeam];
  List<EmployeeRole> roles = [...expectedRoles];
  Failure? failure;
  Failure? rolesFailure;
  Failure? addFailure;
  Completer<void>? gate;
  final added = <NewEmployee>[];
  final passwords = <String>[];

  @override
  Future<Either<Failure, List<TeamMember>>> getTeamMembers() async {
    await gate?.future;
    return failure != null ? Left(failure!) : Right(members);
  }

  @override
  Future<Either<Failure, List<EmployeeRole>>> getEmployeeRoles() async =>
      rolesFailure != null ? Left(rolesFailure!) : Right(roles);

  @override
  Future<Either<Failure, TeamMember>> addEmployee(
    NewEmployee employee, {
    required String temporaryPassword,
  }) async {
    added.add(employee);
    passwords.add(temporaryPassword);
    if (addFailure case final failure?) return Left(failure);
    final member = TeamMember(
      id: 'TM-${(members.length + 1).toString().padLeft(3, '0')}',
      name: employee.displayName,
      role: employee.role.name,
      facilities: 0,
      monthlyVisits: 0,
      lateVisits: 0,
      workload: 0,
      isPendingActivation: true,
      temporaryPassword: temporaryPassword,
    );
    members = [...members, member];
    return Right(member);
  }
}
