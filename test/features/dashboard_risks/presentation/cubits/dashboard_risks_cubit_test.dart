import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/usecases/get_risks.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/cubits/dashboard_risks_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_risks/presentation/cubits/dashboard_risks_state.dart';

import '../../../../helpers/cubit_emissions.dart';
import '../../fixtures/risks_fixture.dart';
import '../../helpers/fake_risks_repository.dart';

void main() {
  late FakeRisksRepository repository;
  late DashboardRisksCubit cubit;

  setUp(() {
    repository = FakeRisksRepository();
    cubit = DashboardRisksCubit(GetRisks(repository));
  });
  tearDown(() => cubit.close());

  DashboardRisksLoaded loaded() => cubit.state as DashboardRisksLoaded;

  test(
    '8. loads through loading, builds the matrix and selects the first risk',
    () async {
      repository.gate = Completer<void>();
      final pending = cubit.load();
      expect(cubit.state, const DashboardRisksLoading());
      repository.gate!.complete();
      await pending;

      // Highest score first: the two lowest swap places.
      expect(loaded().risks, [
        ...expectedRisks.take(5),
        expectedRisks[6],
        expectedRisks[5],
      ]);
      expect(loaded().matrix.total, 7);
      expect(loaded().selectedRisk, expectedRisks.first);
    },
  );

  test('7. selecting a risk updates the details source', () async {
    await cubit.load();

    cubit.selectRisk('RSK-005');

    expect(loaded().selectedRisk!.hazard, 'انسكاب زيوت في الممرات');
    expect(
      loaded().matrix.total,
      7,
      reason: 'selection never rebuilds the matrix data',
    );
  });

  test('unknown ids and re-selecting emit nothing', () async {
    await cubit.load();

    final states = await emissionsOf(cubit, () {
      cubit
        ..selectRisk('RSK-001')
        ..selectRisk('RSK-999');
    });

    expect(states, isEmpty);
  });

  test('an empty register loads with no selection', () async {
    repository.risks = [];

    await cubit.load();

    expect(loaded().selectedRisk, isNull);
    expect(loaded().matrix.total, 0);
  });

  test('a load failure is reported', () async {
    repository.failure = const CacheFailure();

    await cubit.load();

    expect(cubit.state, const DashboardRisksFailure(CacheFailure()));
  });
}
