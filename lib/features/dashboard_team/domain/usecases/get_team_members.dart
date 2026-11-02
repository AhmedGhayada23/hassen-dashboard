import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/team_member.dart';
import '../repositories/team_repository.dart';

class GetTeamMembers extends UseCase<List<TeamMember>, NoParams> {
  final TeamRepository repository;

  GetTeamMembers(this.repository);

  @override
  Future<Either<Failure, List<TeamMember>>> call(NoParams params) =>
      repository.getTeamMembers();
}
