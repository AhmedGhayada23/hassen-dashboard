import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_clients/data/models/client_model.dart';
import 'package:hassen_dashboard/features/dashboard_clients/data/repositories/clients_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_stage.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/clients_summary.dart';

import '../fixtures/clients_fixture.dart';
import '../helpers/fake_clients_remote_datasource.dart';

void main() {
  group('ClientModel.fromDocument', () {
    test('maps a full clients document into a typed entity', () {
      final entity = ClientModel.fromDocument('doc-1', {
        'name': 'بلدية غزة',
        'type': 'مؤسسة حكومية',
        'branches': 5,
        'stage': 'contracted',
        'open_findings': 9,
        'compliance': 76,
        'contract': '2025-12-16 ← 2026-12-15',
        'visits': 'زيارة أسبوعية',
        'inspector': 'م. سارة',
        'contact': 'مدير الخدمات العامة',
        'city': 'غزة',
      }).toEntity();

      expect(
        entity,
        const Client(
          id: 'doc-1',
          name: 'بلدية غزة',
          type: 'مؤسسة حكومية',
          branches: 5,
          stage: ClientStage.contracted,
          openFindings: 9,
          compliance: 76,
          contract: '2025-12-16 ← 2026-12-15',
          visits: 'زيارة أسبوعية',
          inspector: 'م. سارة',
          contact: 'مدير الخدمات العامة',
          city: 'غزة',
        ),
      );
    });

    test('reads a sparse or hand-edited document safely', () {
      final entity = ClientModel.fromDocument('doc-2', {
        'name': ' مصنع ',
        'branches': 2.0,
        'stage': 'archived',
        'open_findings': -3,
      }).toEntity();

      expect(entity.name, 'مصنع');
      expect(
        (entity.branches, entity.stage, entity.openFindings, entity.compliance),
        (2, ClientStage.potential, 0, null),
      );
      expect(
        {
          entity.type,
          entity.contract,
          entity.visits,
          entity.inspector,
          entity.contact,
          entity.city,
        },
        {'—'},
      );
    });
  });

  test('compliance stays null (never 0) for clients without inspections', () {
    expect(expectedClients.map((c) => c.compliance), [
      82,
      76,
      91,
      85,
      94,
      null,
      null,
      null,
    ]);
  });

  test('counts clients per stage: 5 / 1 / 1 / 1', () {
    final summary = ClientsSummary.fromClients(expectedClients);

    expect(summary.countsByStage, {
      ClientStage.potential: 1,
      ClientStage.inspection: 1,
      ClientStage.quotation: 1,
      ClientStage.contracted: 5,
    });
    expect(summary.countFor(null), 8);
    expect(
      ClientsSummary.fromClients(const []).countFor(ClientStage.contracted),
      0,
    );
  });

  test('more than 5 open findings flags the client', () {
    expect(
      [for (final c in expectedClients) c.hasManyOpenFindings],
      [true, true, false, false, false, false, false, false],
    );
  });

  group('repository', () {
    test('maps the Firebase clients into entities, in order', () async {
      final result = await ClientsRepositoryImpl(
        FakeClientsRemoteDataSource(),
      ).getClients();

      expect(result.getOrElse(() => []), expectedClients);
    });

    test(
      'an empty clients collection is an empty list, not an error',
      () async {
        final remote = FakeClientsRemoteDataSource()..clients = [];

        expect(
          await ClientsRepositoryImpl(remote).getClients(),
          isA<Right<Failure, List<Client>>>().having(
            (r) => r.getOrElse(() => [expectedClients.first]),
            'clients',
            isEmpty,
          ),
        );
      },
    );

    test('Firestore errors become failures the page can explain', () async {
      final remote = FakeClientsRemoteDataSource();
      final repository = ClientsRepositoryImpl(remote);
      Future<Failure> failureFor(String code) async {
        remote.error = FirebaseException(plugin: 'cloud_firestore', code: code);
        return (await repository.getClients()).fold(
          (f) => f,
          (_) => throw StateError('no failure'),
        );
      }

      expect(await failureFor('permission-denied'), const ForbiddenFailure());
      expect(await failureFor('unavailable'), const NetworkFailure());
      expect(await failureFor('internal'), isA<UnknownFailure>());
    });
  });
}
