import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/exceptions.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/data/datasources/contracts_local_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/data/models/deal_model.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/entities/deal.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/entities/deal_status.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/failures/deal_failures.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/repositories/contracts_repository.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/usecases/decide_deal.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/usecases/get_deals.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/domain/usecases/set_contract_plan.dart';

import '../fixtures/contracts_fixture.dart';
import '../helpers/contracts_cubit_factory.dart';
import '../helpers/fake_contracts_remote_datasource.dart';

void main() {
  late FakeContractsRemoteDataSource remote;
  late ContractsRepository repository;

  setUp(() {
    remote = FakeContractsRemoteDataSource();
    repository = buildContractsRepository(remote);
  });

  Future<List<Deal>> deals() async =>
      (await repository.getDeals()).getOrElse(() => throw StateError('none'));

  group('contract plan', () {
    test('runs to the day before the same date N months later', () {
      expect(monthly.endFor(DateTime(2026, 11, 2)), DateTime(2026, 12, 1));
      expect(halfYear.endFor(DateTime(2026, 7, 1)), DateTime(2026, 12, 31));
      expect(yearly.endFor(DateTime(2025, 12, 16)), DateTime(2026, 12, 15));
    });

    test('the lengths on offer are the original four', () async {
      expect(
        (await repository.getContractPlans()).getOrElse(() => []),
        expectedPlans,
      );
      expect(
        const ContractsLocalDataSource(
          plansJson: [
            {'id': 'z', 'name': 'صفر', 'months': 0},
          ],
        ).getContractPlans(),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('reading the clients', () {
    test(
      'one deal per client, oldest first, numbered within its year',
      () async {
        expect(await deals(), expectedDeals);
      },
    );

    test('a client still being saved comes last, numbered this year', () {
      final read = DealModel.fromClients([
        (id: 'new', json: const {'name': 'عميل جديد'}, createdAt: null),
        ...clientRecords(),
        (id: 'blank', json: const {'name': '  '}, createdAt: DateTime(2026)),
      ], currentYear: 2026);

      expect(read.map((d) => d.id), [...expectedDeals.map((d) => d.id), 'new']);
      expect(
        (read.last.number, read.last.date, read.last.status),
        ('Q-2026-006', '—', DealStatus.pending),
      );
    });

    test('pending first, then accepted, then rejected; newest first', () async {
      final ordered = (await GetDeals(repository)(
        const NoParams(),
      )).getOrElse(() => []);

      expect(ordered.map((d) => d.id), [
        'c-mall',
        'c-school',
        'c-factory',
        'c-shifa',
        'c-bank',
        'c-power',
        'c-gaza',
        'c-transport',
      ]);
    });

    test('Firestore errors become failures the page can explain', () async {
      Future<Failure> failureFor(String code) async {
        remote.error = FirebaseException(plugin: 'cloud_firestore', code: code);
        return (await repository.getDeals()).fold(
          (f) => f,
          (_) => throw StateError('no failure'),
        );
      }

      expect(await failureFor('permission-denied'), const ForbiddenFailure());
      expect(await failureFor('unavailable'), const NetworkFailure());
      expect(await failureFor('internal'), isA<UnknownFailure>());
    });
  });

  group('writing the decision to the client', () {
    test('accepting: contracted from today, length still open', () async {
      final accepted = (await AcceptDeal(
        repository,
        clock: () => contractsToday,
      )(dealOf('c-mall'))).getOrElse(() => throw StateError('not accepted'));

      expect(remote.updates.single.$1, 'c-mall');
      expect(remote.updates.single.$2, {
        'deal_status': 'accepted',
        'stage': 'contracted',
        'contract_start': '2026-11-02',
        'contract_plan': null,
        'contract': '—',
      });
      expect(
        (accepted.status, accepted.startDate, accepted.planId),
        (DealStatus.accepted, DateTime(2026, 11, 2), null),
      );
      expect((await deals()).last, accepted);
    });

    test('a length writes the period the clients page shows', () async {
      await SetContractPlan(repository)(
        SetContractPlanParams(dealOf('c-power'), yearly),
      );

      expect(remote.updates.single.$1, 'c-power');
      expect(remote.updates.single.$2, {
        'contract_plan': 'y',
        'contract_start': '2026-07-01',
        'contract': '2026-07-01 ← 2027-06-30',
      });
      expect((await deals()).singleWhere((d) => d.id == 'c-power').planId, 'y');
    });

    test('rejecting: back to quotation, with no contract', () async {
      final rejected = (await RejectDeal(repository)(
        dealOf('c-school'),
      )).getOrElse(() => throw StateError('not rejected'));

      expect(remote.updates.single.$1, 'c-school');
      expect(remote.updates.single.$2, {
        'deal_status': 'rejected',
        'stage': 'quotation',
        'contract_start': null,
        'contract_plan': null,
        'contract': '—',
      });
      expect(rejected.status, DealStatus.rejected);
    });

    test('a decision can be changed either way', () async {
      final cancelled = (await RejectDeal(repository)(
        dealOf('c-shifa'),
      )).getOrElse(() => throw StateError('not rejected'));
      expect(
        (cancelled.status, cancelled.planId, cancelled.startDate),
        (DealStatus.rejected, null, null),
      );

      final reaccepted = (await AcceptDeal(
        repository,
        clock: () => contractsToday,
      )(dealOf('c-transport'))).getOrElse(() => throw StateError('no'));
      expect(reaccepted.status, DealStatus.accepted);
    });

    test('the same decision twice is refused, nothing written', () async {
      expect(
        await AcceptDeal(repository)(dealOf('c-bank')),
        const Left<Failure, Deal>(DealAlreadyDecidedFailure()),
      );
      expect(
        await RejectDeal(repository)(dealOf('c-transport')),
        const Left<Failure, Deal>(DealAlreadyDecidedFailure()),
      );
      expect(remote.updates, isEmpty);
    });

    test(
      'only an accepted deal takes a length; one with no start begins today',
      () async {
        expect(
          await SetContractPlan(repository)(
            SetContractPlanParams(dealOf('c-mall'), yearly),
          ),
          const Left<Failure, Deal>(DealNotAcceptedFailure()),
        );

        const legacy = Deal(
          id: 'c-mall',
          number: 'Q-2026-005',
          client: 'مجمع تجاري — المنطقة الوسطى',
          date: '2026-10-20',
          status: DealStatus.accepted,
        );
        final set =
            (await SetContractPlan(repository, clock: () => contractsToday)(
              SetContractPlanParams(legacy, monthly),
            )).getOrElse(() => throw StateError('not set'));
        expect(set.startDate, DateTime(2026, 11, 2));
        expect(remote.updates.single.$2['contract'], '2026-11-02 ← 2026-12-01');
      },
    );
  });
}
