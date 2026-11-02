import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/dashboard_overview.dart';

/// Contract the data layer implements; the domain never knows where data comes from.
abstract interface class DashboardRepository {
  Future<Either<Failure, DashboardOverview>> getOverview();
}
