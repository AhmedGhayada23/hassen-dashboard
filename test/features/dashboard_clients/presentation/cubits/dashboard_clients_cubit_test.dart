import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_stage.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/add_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/get_client_registration_options.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/get_clients.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/cubits/dashboard_clients_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/cubits/dashboard_clients_state.dart';

import '../../../../helpers/cubit_emissions.dart';
import '../../fixtures/clients_fixture.dart';
import '../../helpers/fake_clients_repository.dart';

void main() {
  late FakeClientsRepository repository;
  late DashboardClientsCubit cubit;

  setUp(() {
    repository = FakeClientsRepository();
    cubit = DashboardClientsCubit(
      GetClients(repository),
      GetClientRegistrationOptions(repository),
      AddClient(repository),
    );
  });
  tearDown(() => cubit.close());

  DashboardClientsLoaded loaded() => cubit.state as DashboardClientsLoaded;
  List<String> visibleNames() =>
      loaded().visibleClients.map((c) => c.name).toList();

  test('5. loads through loading, selecting the first client', () async {
    repository.gate = Completer<void>();
    final pending = cubit.load();
    expect(cubit.state, const DashboardClientsLoading());
    repository.gate!.complete();
    await pending;

    expect(loaded().clients, expectedClients);
    expect(loaded().stageFilter, isNull);
    expect(loaded().selectedClient!.name, 'مستشفى الشفاء');
  });

  test('a load failure is reported', () async {
    repository.failure = const CacheFailure();

    await cubit.load();

    expect(cubit.state, const DashboardClientsFailure(CacheFailure()));
  });

  group('filtering', () {
    setUp(() => cubit.load());

    test('6. "الكل" shows all eight', () {
      cubit
        ..selectStage(ClientStage.potential)
        ..selectStage(null);

      expect(loaded().visibleClients, expectedClients);
    });

    test('7–10. each stage shows only its clients', () {
      final expected = {
        ClientStage.contracted: [
          'مستشفى الشفاء',
          'بلدية غزة',
          'شركة كهرباء غزة',
          'مصنع العودة',
          'بنك فلسطين',
        ],
        ClientStage.quotation: ['مجمع تجاري — المنطقة الوسطى'],
        ClientStage.inspection: ['مدرسة خاصة — غزة'],
        ClientStage.potential: ['شركة نقل وخدمات لوجستية'],
      };
      for (final MapEntry(key: stage, value: names) in expected.entries) {
        cubit.selectStage(stage);
        expect(visibleNames(), names, reason: '$stage');
      }
    });

    test('11. keeps the selected client when it is still in the results', () {
      cubit
        ..selectClient('CL-005')
        ..selectStage(ClientStage.contracted);

      expect(loaded().selectedClient!.name, 'بنك فلسطين');
    });

    test(
      '12. falls back to the first result when the selection is filtered out',
      () {
        cubit
          ..selectClient('CL-005')
          ..selectStage(ClientStage.inspection);

        expect(loaded().selectedClient!.name, 'مدرسة خاصة — غزة');

        cubit.selectStage(null);
        expect(
          loaded().selectedClient!.name,
          'مدرسة خاصة — غزة',
          reason: 'still visible under "الكل"',
        );
      },
    );

    test(
      'selection is by id: rows hidden by the filter cannot be selected',
      () {
        cubit
          ..selectStage(ClientStage.quotation)
          ..selectClient('CL-001');

        expect(loaded().selectedClientId, 'CL-006');
      },
    );

    test('re-selecting the same stage or client emits nothing', () async {
      final states = await emissionsOf(cubit, () {
        cubit
          ..selectStage(null)
          ..selectClient('CL-001');
      });

      expect(states, isEmpty);
    });
  });

  test('13. an empty stage clears the selection without errors', () async {
    repository.clients = [
      for (final c in expectedClients)
        if (c.stage != ClientStage.potential) c,
    ];
    await cubit.load();

    cubit.selectStage(ClientStage.potential);

    expect(loaded().visibleClients, isEmpty);
    expect(loaded().selectedClientId, isNull);
    expect(loaded().selectedClient, isNull);

    cubit.selectStage(ClientStage.quotation);
    expect(loaded().selectedClient!.name, 'مجمع تجاري — المنطقة الوسطى');
  });

  test('an empty client list loads with no selection', () async {
    repository.clients = [];

    await cubit.load();

    expect(loaded().selectedClient, isNull);
    expect(loaded().summary.countFor(null), 0);
  });

  test('14. per-stage counts come from the loaded data', () async {
    await cubit.load();

    final summary = loaded().summary;
    expect(
      [
        for (final s in [null, ...ClientStage.values.reversed])
          summary.countFor(s),
      ],
      [8, 5, 1, 1, 1],
    );
  });
}
