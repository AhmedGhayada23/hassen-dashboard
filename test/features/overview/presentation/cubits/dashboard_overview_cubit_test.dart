import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/overview/domain/usecases/get_dashboard_overview.dart';
import 'package:hassen_dashboard/features/overview/presentation/cubits/dashboard_overview_cubit.dart';
import 'package:hassen_dashboard/features/overview/presentation/cubits/dashboard_overview_state.dart';

import '../../../../helpers/cubit_emissions.dart';
import '../../fixtures/overview_fixture.dart';
import '../../helpers/fake_dashboard_repository.dart';

void main() {
  late FakeDashboardRepository repository;
  late DashboardOverviewCubit cubit;

  setUp(() {
    repository = FakeDashboardRepository(Right(expectedOverview));
    cubit = DashboardOverviewCubit(GetDashboardOverview(repository));
  });
  tearDown(() => cubit.close());

  test('starts in the initial state without loading', () {
    expect(cubit.state, const DashboardOverviewInitial());
    expect(repository.calls, 0);
  });

  test('is loading while the use case runs', () async {
    repository.gate = Completer<void>();

    final pending = cubit.load();

    expect(cubit.state, const DashboardOverviewLoading());
    repository.gate!.complete();
    await pending;
  });

  test('emits loading then success with the full overview', () async {
    final states = await emissionsOf(cubit, cubit.load);

    expect(states, [
      const DashboardOverviewLoading(),
      DashboardOverviewLoaded(expectedOverview),
    ]);
    expect((cubit.state as DashboardOverviewLoaded).overview, expectedOverview);
  });

  test('emits loading then failure when the repository fails', () async {
    repository.result = const Left(CacheFailure(message: 'boom'));

    final states = await emissionsOf(cubit, cubit.load);

    expect(states, [
      const DashboardOverviewLoading(),
      const DashboardOverviewFailure(CacheFailure(message: 'boom')),
    ]);
  });

  test('can retry after a failure', () async {
    repository.result = const Left(CacheFailure());
    await cubit.load();

    repository.result = Right(expectedOverview);
    await cubit.load();

    expect(cubit.state, DashboardOverviewLoaded(expectedOverview));
    expect(repository.calls, 2);
  });
}
