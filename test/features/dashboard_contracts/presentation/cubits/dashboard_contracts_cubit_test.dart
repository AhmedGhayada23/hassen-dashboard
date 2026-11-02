import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/entities/deal.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/entities/deal_status.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/cubits/dashboard_contracts_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/presentation/cubits/dashboard_contracts_state.dart';

import '../../../../helpers/cubit_emissions.dart';
import '../../fixtures/contracts_fixture.dart';
import '../../helpers/contracts_cubit_factory.dart';
import '../../helpers/fake_contracts_remote_datasource.dart';

/// Holds every update until [gate] completes.
class _SlowRemote extends FakeContractsRemoteDataSource {
  final gate = Completer<void>();

  @override
  Future<void> updateDeal(String id, Map<String, Object?> changes) async {
    await gate.future;
    return super.updateDeal(id, changes);
  }
}

void main() {
  late FakeContractsRemoteDataSource remote;
  late DashboardContractsCubit cubit;

  setUp(() {
    remote = FakeContractsRemoteDataSource();
    cubit = buildContractsCubit(buildContractsRepository(remote));
  });
  tearDown(() => cubit.close());

  DashboardContractsLoaded loaded() => cubit.state as DashboardContractsLoaded;
  Deal shown(String id) => loaded().deals.singleWhere((d) => d.id == id);

  test('emits loading then the clients\' deals, pending first', () async {
    final states = await emissionsOf(cubit, cubit.load);

    expect(states.first, const DashboardContractsLoading());
    final last = states.last as DashboardContractsLoaded;
    expect(last.plans, expectedPlans);
    expect(last.deals.map((d) => d.id).take(2), ['c-mall', 'c-school']);
    expect(last.deals, hasLength(8));
  });

  test('a Firestore failure fails the page', () async {
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );

    await cubit.load();

    expect(cubit.state, const DashboardContractsFailure(ForbiddenFailure()));
  });

  test('accepting starts the contract today and confirms once', () async {
    await cubit.load();

    await cubit.accept(shown('c-mall'));

    final deal = shown('c-mall');
    expect(
      (deal.status, deal.startDate),
      (DealStatus.accepted, DateTime(2026, 11, 2)),
    );
    expect(loaded().lastDecided, deal);
    expect(loaded().savingIds, isEmpty);
    // It keeps its place in the list.
    expect(loaded().deals.first.id, 'c-mall');
  });

  test(
    'an accepted deal can be rejected, and a rejected one accepted',
    () async {
      await cubit.load();

      await cubit.reject(shown('c-bank'));
      expect(shown('c-bank').status, DealStatus.rejected);
      expect(loaded().lastDecided?.id, 'c-bank');

      await cubit.accept(shown('c-transport'));
      expect(shown('c-transport').status, DealStatus.accepted);
    },
  );

  test('picking a length saves it without a confirmation', () async {
    await cubit.load();

    await cubit.selectPlan(shown('c-power'), quarterly);

    expect(shown('c-power').planId, 'q');
    expect((loaded().lastDecided, loaded().actionFailure), (null, null));
  });

  test('a change that can\'t be saved is reported, the list kept', () async {
    await cubit.load();
    final before = loaded().deals;
    remote.error = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );

    await cubit.accept(shown('c-mall'));

    expect(loaded().deals, before);
    expect(loaded().actionFailure, const ForbiddenFailure());
  });

  test(
    'while a deal saves it is marked, and a second tap is ignored',
    () async {
      final slow = _SlowRemote();
      cubit = buildContractsCubit(buildContractsRepository(slow));
      await cubit.load();

      final pending = cubit.accept(shown('c-mall'));
      await Future<void>.delayed(Duration.zero);
      expect(loaded().savingIds, {'c-mall'});

      await cubit.reject(shown('c-mall'));
      slow.gate.complete();
      await pending;

      expect(slow.updates, hasLength(1));
      expect(shown('c-mall').status, DealStatus.accepted);
      expect(loaded().savingIds, isEmpty);
    },
  );

  test('is ignored before the deals have loaded', () async {
    await cubit.accept(dealOf('c-mall'));

    expect(cubit.state, const DashboardContractsInitial());
    expect(remote.updates, isEmpty);
  });
}
