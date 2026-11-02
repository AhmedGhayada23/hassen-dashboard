import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/dashboard_overview.dart';
import 'package:hassen_dashboard/features/overview/domain/repositories/dashboard_repository.dart';

/// Repository stub: returns [result], optionally held until [gate] completes.
class FakeDashboardRepository implements DashboardRepository {
  Either<Failure, DashboardOverview> result;
  Completer<void>? gate;
  int calls = 0;

  FakeDashboardRepository(this.result);

  @override
  Future<Either<Failure, DashboardOverview>> getOverview() async {
    calls++;
    await gate?.future;
    return result;
  }
}
