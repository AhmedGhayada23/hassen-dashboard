import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/cubits/dashboard_settings_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_settings/presentation/cubits/dashboard_settings_state.dart';

import '../../../../helpers/cubit_emissions.dart';
import '../../fixtures/settings_fixture.dart';
import '../../helpers/settings_cubit_factory.dart';

void main() {
  late FakeSettingsRepository repository;
  late DashboardSettingsCubit cubit;

  setUp(() {
    repository = FakeSettingsRepository();
    cubit = buildSettingsCubit(repository);
  });
  tearDown(() => cubit.close());

  test('starts in the initial state without loading', () {
    expect(cubit.state, const DashboardSettingsInitial());
  });

  test('is loading while the use cases run', () async {
    repository.gate = Completer<void>();

    final pending = cubit.load();

    expect(cubit.state, const DashboardSettingsLoading());
    repository.gate!.complete();
    await pending;
  });

  test('emits loading then all three lists', () async {
    final states = await emissionsOf(cubit, cubit.load);

    expect(states, [
      const DashboardSettingsLoading(),
      const DashboardSettingsLoaded(
        templates: expectedTemplates,
        roles: expectedRoles,
        rules: expectedRules,
      ),
    ]);
  });

  test('one list failing fails the page, and a retry recovers', () async {
    repository.rolesFailure = const CacheFailure(message: 'roles');

    await cubit.load();
    expect(
      cubit.state,
      const DashboardSettingsFailure(CacheFailure(message: 'roles')),
    );

    repository.rolesFailure = null;
    await cubit.load();
    expect(cubit.state, isA<DashboardSettingsLoaded>());
  });
}
