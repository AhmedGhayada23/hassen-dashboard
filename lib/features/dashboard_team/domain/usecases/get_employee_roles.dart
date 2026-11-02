import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_role.dart';
import '../repositories/team_repository.dart';

class GetEmployeeRoles extends UseCase<List<EmployeeRole>, NoParams> {
  final TeamRepository repository;

  GetEmployeeRoles(this.repository);

  @override
  Future<Either<Failure, List<EmployeeRole>>> call(NoParams params) =>
      repository.getEmployeeRoles();
}
