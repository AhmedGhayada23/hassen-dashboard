import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/employee_role.dart';
import '../../domain/entities/new_employee.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/failures/team_failures.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_remote_datasource.dart';

class TeamRepositoryImpl implements TeamRepository {
  final TeamRemoteDataSource remoteDataSource;

  const TeamRepositoryImpl(this.remoteDataSource);

  /// The employees in the `users` collection.
  @override
  Future<Either<Failure, List<TeamMember>>> getTeamMembers() => _guard(
    () async => [
      for (final m in await remoteDataSource.getEmployees()) m.toEntity(),
    ],
  );

  /// The roles in the `roles` collection.
  @override
  Future<Either<Failure, List<EmployeeRole>>> getEmployeeRoles() => _guard(
    () async => [
      for (final r in await remoteDataSource.getEmployeeRoles()) r.toEntity(),
    ],
  );

  @override
  Future<Either<Failure, TeamMember>> addEmployee(
    NewEmployee employee, {
    required String temporaryPassword,
  }) => _guard(
    () async => (await remoteDataSource.addEmployee(
      name: employee.displayName,
      email: employee.email.trim(),
      phone: employee.phone.trim(),
      roleId: employee.role.id,
      roleName: employee.role.name,
      temporaryPassword: temporaryPassword,
    )).toEntity(),
  );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on FirebaseAuthException catch (e) {
      return Left(switch (e.code) {
        'email-already-in-use' => const EmailAlreadyInUseFailure(),
        'network-request-failed' => const NetworkFailure(),
        _ => UnknownFailure(message: e.message ?? e.code),
      });
    } on FirebaseException catch (e) {
      return Left(switch (e.code) {
        'permission-denied' => const ForbiddenFailure(),
        'unavailable' => const NetworkFailure(),
        _ => UnknownFailure(message: e.message ?? e.code),
      });
    } on AppException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
