import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/add_employee.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/get_employee_roles.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/get_team_members.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/cubits/dashboard_team_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/cubits/dashboard_team_state.dart';

import '../../fixtures/team_fixture.dart';
import '../../helpers/fake_team_repository.dart';

void main() {
  late FakeTeamRepository repository;
  late DashboardTeamCubit cubit;

  setUp(() {
    repository = FakeTeamRepository();
    cubit = DashboardTeamCubit(
      GetTeamMembers(repository),
      GetEmployeeRoles(repository),
      AddEmployee(repository),
    );
  });
  tearDown(() => cubit.close());

  test('loads the roster through loading and exposes its summary', () async {
    repository.gate = Completer<void>();
    final pending = cubit.load();
    expect(cubit.state, const DashboardTeamLoading());
    repository.gate!.complete();
    await pending;

    final state = cubit.state as DashboardTeamLoaded;
    expect(state.members, expectedTeam);
    expect((state.summary.memberCount, state.summary.overloadedCount), (6, 1));
  });

  test('a load failure is reported', () async {
    repository.failure = const CacheFailure();

    await cubit.load();

    expect(cubit.state, const DashboardTeamFailure(CacheFailure()));
  });
}
