import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/new_employee.dart';
import '../entities/team_member.dart';
import '../entities/temporary_password.dart';
import '../repositories/team_repository.dart';

/// Creates [NewEmployee]'s account with a freshly generated temporary
/// password; refuses one without a name or email.
class AddEmployee extends UseCase<TeamMember, NewEmployee> {
  final TeamRepository repository;
  final String Function() _generatePassword;

  AddEmployee(this.repository, {String Function()? generatePassword})
    : _generatePassword = generatePassword ?? TemporaryPassword.generate;

  @override
  Future<Either<Failure, TeamMember>> call(NewEmployee employee) async {
    if (!employee.isComplete) {
      return const Left(
        ValidationFailure(message: 'A new employee needs a name and email.'),
      );
    }
    return repository.addEmployee(
      employee,
      temporaryPassword: _generatePassword(),
    );
  }
}
