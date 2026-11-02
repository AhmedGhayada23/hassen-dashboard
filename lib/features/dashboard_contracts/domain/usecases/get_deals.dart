import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/deal.dart';
import '../entities/deal_status.dart';
import '../repositories/contracts_repository.dart';

/// Every client's deal: those awaiting a decision first, then the accepted,
/// then the rejected; newest client first within each.
class GetDeals extends UseCase<List<Deal>, NoParams> {
  final ContractsRepository repository;

  GetDeals(this.repository);

  @override
  Future<Either<Failure, List<Deal>>> call(NoParams params) async =>
      (await repository.getDeals()).map(
        (deals) => [
          for (final status in DealStatus.values)
            ...deals.reversed.where((d) => d.status == status),
        ],
      );
}
