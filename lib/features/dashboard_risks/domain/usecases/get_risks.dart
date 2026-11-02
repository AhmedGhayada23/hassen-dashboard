import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/risk.dart';
import '../repositories/risks_repository.dart';

/// The risk register, highest score first; equal scores keep the order they
/// were added in.
class GetRisks extends UseCase<List<Risk>, NoParams> {
  final RisksRepository repository;

  GetRisks(this.repository);

  @override
  Future<Either<Failure, List<Risk>>> call(NoParams params) async =>
      (await repository.getRisks()).map(
        (risks) => [
          for (final (_, risk)
              in risks.indexed.toList()..sort((a, b) {
                final byScore = b.$2.score.compareTo(a.$2.score);
                return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
              }))
            risk,
        ],
      );
}
