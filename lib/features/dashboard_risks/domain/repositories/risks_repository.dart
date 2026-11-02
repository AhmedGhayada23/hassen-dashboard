import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/risk.dart';

abstract interface class RisksRepository {
  Future<Either<Failure, List<Risk>>> getRisks();
}
