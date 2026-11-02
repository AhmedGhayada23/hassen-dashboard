import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/domain/entities/nav_destination.dart';
import 'package:hassen_dashboard/shared/dashboard_shell/presentation/cubits/dashboard_navigation_cubit.dart';

import '../../../../helpers/cubit_emissions.dart';

void main() {
  late DashboardNavigationCubit cubit;

  setUp(() => cubit = DashboardNavigationCubit());
  tearDown(() => cubit.close());

  test('defaults to نظرة عامة (overview), where the app opens', () {
    expect(cubit.state, NavDestination.overview);
  });

  test('accepts a custom initial destination', () async {
    final custom = DashboardNavigationCubit(initial: NavDestination.reports);
    addTearDown(custom.close);

    expect(custom.state, NavDestination.reports);
  });

  test('select emits the new destination once', () async {
    final states = await emissionsOf(
      cubit,
      () => cubit.select(NavDestination.reports),
    );

    expect(states, [NavDestination.reports]);
    expect(cubit.state, NavDestination.reports);
  });

  test('keeps the last selected value', () async {
    final states = await emissionsOf(cubit, () {
      cubit
        ..select(NavDestination.team)
        ..select(NavDestination.settings);
    });

    expect(states, [NavDestination.team, NavDestination.settings]);
    expect(cubit.state, NavDestination.settings);
  });

  test('re-selecting the active destination emits nothing', () async {
    final states = await emissionsOf(
      cubit,
      () => cubit.select(NavDestination.overview),
    );

    expect(states, isEmpty);
  });
}
