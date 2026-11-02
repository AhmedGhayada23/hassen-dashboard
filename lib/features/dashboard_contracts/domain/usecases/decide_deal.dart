import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/deal.dart';
import '../failures/deal_failures.dart';
import '../repositories/contracts_repository.dart';

/// Accepts a pending or rejected deal; the contract starts today.
class AcceptDeal extends UseCase<Deal, Deal> {
  final ContractsRepository repository;
  final DateTime Function() _clock;

  AcceptDeal(this.repository, {DateTime Function() clock = DateTime.now})
    : _clock = clock;

  @override
  Future<Either<Failure, Deal>> call(Deal deal) async {
    if (deal.isAccepted) return const Left(DealAlreadyDecidedFailure());
    return repository.acceptDeal(deal, today(_clock));
  }
}

/// Rejects a pending deal, or cancels an accepted one.
class RejectDeal extends UseCase<Deal, Deal> {
  final ContractsRepository repository;

  RejectDeal(this.repository);

  @override
  Future<Either<Failure, Deal>> call(Deal deal) async {
    if (deal.isRejected) return const Left(DealAlreadyDecidedFailure());
    return repository.rejectDeal(deal);
  }
}

/// Midnight of the clock's day.
DateTime today(DateTime Function() clock) {
  final now = clock();
  return DateTime(now.year, now.month, now.day);
}
