import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_overview.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardOverview extends UseCase<DashboardOverview, NoParams> {
  final DashboardRepository repository;

  GetDashboardOverview(this.repository);

  @override
  Future<Either<Failure, DashboardOverview>> call(NoParams params) =>
      repository.getOverview();
}
