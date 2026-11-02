import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/overview/domain/usecases/get_dashboard_overview.dart';

import '../../fixtures/overview_fixture.dart';
import '../../helpers/fake_dashboard_repository.dart';

void main() {
  test('returns the repository overview', () async {
    final repository = FakeDashboardRepository(Right(expectedOverview));

    final result = await GetDashboardOverview(repository)(const NoParams());

    expect(result, Right(expectedOverview));
    expect(repository.calls, 1);
  });

  test('passes repository failures through', () async {
    final repository = FakeDashboardRepository(const Left(CacheFailure()));

    final result = await GetDashboardOverview(repository)(const NoParams());

    expect(result, const Left(CacheFailure()));
  });
}
