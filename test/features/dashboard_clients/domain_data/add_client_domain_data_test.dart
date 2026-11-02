import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/dashboard_clients/data/repositories/clients_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_registration_options.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_stage.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/new_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/failures/client_failures.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/add_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/get_client_registration_options.dart';

import '../fixtures/clients_fixture.dart';
import '../helpers/fake_clients_remote_datasource.dart';
import '../helpers/fake_clients_repository.dart';

const _school = NewClient(
  name: 'مدرسة النور',
  sector: 'مؤسسة تعليمية',
  branches: 2,
  city: 'خان يونس',
  address: 'شارع البحر',
  contactName: 'أ. محمود',
  contactTitle: 'مدير المدرسة',
  email: 'nour@school.ps',
  stage: ClientStage.inspection,
  inspector: 'م. ليلى',
);

void main() {
  group('NewClient display lines (the original rules)', () {
    test('contact is "name — title", or the name alone', () {
      expect(_school.contactLine, 'أ. محمود — مدير المدرسة');
      expect(
        const NewClient(
          name: 'n',
          sector: 's',
          branches: 1,
          contactName: ' أ. محمود ',
          stage: ClientStage.potential,
        ).contactLine,
        'أ. محمود',
      );
    });

    test('city joins city and address with "، ", skipping blanks, or "—"', () {
      expect(_school.cityLine, 'خان يونس، شارع البحر');
      NewClient only({String city = '', String address = ''}) => NewClient(
        name: 'n',
        sector: 's',
        branches: 1,
        city: city,
        address: address,
        contactName: 'c',
        stage: ClientStage.potential,
      );
      expect(only(city: 'رفح').cityLine, 'رفح');
      expect(only(address: 'شارع الجلاء').cityLine, 'شارع الجلاء');
      expect(only(city: ' ', address: '').cityLine, '—');
    });

    test('visits and inspector fall back to "—"', () {
      expect(_school.visitsLine, 'فحص أولي مطلوب');
      expect(_school.inspectorLine, 'م. ليلى');
      const later = NewClient(
        name: 'n',
        sector: 's',
        branches: 1,
        contactName: 'c',
        stage: ClientStage.potential,
        schedulePreInspection: false,
      );
      expect((later.visitsLine, later.inspectorLine), ('—', '—'));
    });

    test('a new client starts as potential, inspection or quotation only', () {
      expect(ClientStage.forNewClient, [
        ClientStage.potential,
        ClientStage.inspection,
        ClientStage.quotation,
      ]);
    });
  });

  test('the suggested inspector is the least loaded, first on a tie', () {
    expect(expectedRegistrationOptions.suggestedInspector?.name, 'م. ليلى');
    const tie = ClientRegistrationOptions(
      sectors: ['s'],
      inspectors: [
        InspectorLoad(name: 'أ', weeklyVisits: 1),
        InspectorLoad(name: 'ب', weeklyVisits: 1),
      ],
    );
    expect(tie.suggestedInspector?.name, 'أ');
    expect(
      const ClientRegistrationOptions(
        sectors: [],
        inspectors: [],
      ).suggestedInspector,
      isNull,
    );
  });

  group('AddClient', () {
    test('registers a valid client', () async {
      final repository = FakeClientsRepository();

      final result = await AddClient(repository)(_school);

      expect(repository.added, [_school]);
      final client = result.getOrElse(() => throw StateError('no client'));
      expect(
        (
          client.id,
          client.name,
          client.city,
          client.contract,
          client.compliance,
        ),
        ('CL-009', 'مدرسة النور', 'خان يونس، شارع البحر', '—', null),
      );
    });

    test('refuses a name already registered', () async {
      final repository = FakeClientsRepository();

      final result = await AddClient(repository)(
        const NewClient(
          name: ' بلدية غزة ',
          sector: 'مؤسسة حكومية',
          branches: 1,
          contactName: 'c',
          stage: ClientStage.potential,
        ),
      );

      expect(result, const Left<Failure, Client>(DuplicateClientFailure()));
      expect(repository.added, isEmpty);
    });

    test('refuses incomplete data and the contracted stage', () async {
      final repository = FakeClientsRepository();
      for (final bad in [
        const NewClient(
          name: ' ',
          sector: 's',
          branches: 1,
          contactName: 'c',
          stage: ClientStage.potential,
        ),
        const NewClient(
          name: 'n',
          sector: '',
          branches: 1,
          contactName: 'c',
          stage: ClientStage.potential,
        ),
        const NewClient(
          name: 'n',
          sector: 's',
          branches: 0,
          contactName: 'c',
          stage: ClientStage.potential,
        ),
        const NewClient(
          name: 'n',
          sector: 's',
          branches: 1,
          contactName: ' ',
          stage: ClientStage.potential,
        ),
        const NewClient(
          name: 'n',
          sector: 's',
          branches: 1,
          contactName: 'c',
          stage: ClientStage.contracted,
        ),
      ]) {
        final result = await AddClient(repository)(bad);
        expect(result.isLeft(), isTrue, reason: '$bad');
      }
      expect(repository.added, isEmpty);
    });

    test(
      'GetClientRegistrationOptions returns the repository options',
      () async {
        expect(
          await GetClientRegistrationOptions(FakeClientsRepository())(
            const NoParams(),
          ),
          const Right<Failure, ClientRegistrationOptions>(
            expectedRegistrationOptions,
          ),
        );
      },
    );
  });

  group('data', () {
    test('the options are the Firebase sectors and inspectors', () async {
      final remote = FakeClientsRemoteDataSource()
        ..sectors = ['منشأة صحية', 'أخرى']
        ..inspectors = const [InspectorLoad(name: 'م. رامي', weeklyVisits: 0)];

      final options =
          (await ClientsRepositoryImpl(remote).getRegistrationOptions())
              .getOrElse(() => throw StateError('no options'));

      expect(options.sectors, ['منشأة صحية', 'أخرى']);
      expect(options.inspectors.map((i) => i.name), ['م. رامي']);
      expect(options.suggestedInspector?.name, 'م. رامي');
    });

    test('a refused or unreachable read becomes a clear failure', () async {
      final remote = FakeClientsRemoteDataSource();
      final repository = ClientsRepositoryImpl(remote);
      Future<Failure> failureFor(String code) async {
        remote.error = FirebaseException(plugin: 'cloud_firestore', code: code);
        return (await repository.getRegistrationOptions()).fold(
          (f) => f,
          (_) => throw StateError('no failure'),
        );
      }

      expect(await failureFor('permission-denied'), const ForbiddenFailure());
      expect(await failureFor('unavailable'), const NetworkFailure());
    });

    test(
      'a new client is stored in clients with its display lines and contact details',
      () async {
        final remote = FakeClientsRemoteDataSource();
        final repository = ClientsRepositoryImpl(remote);

        final result = await repository.addClient(_school);

        expect(remote.documents.single, {
          'name': 'مدرسة النور',
          'type': 'مؤسسة تعليمية',
          'branches': 2,
          'stage': 'inspection',
          'open_findings': 0,
          'compliance': null,
          'contract': '—',
          'visits': 'فحص أولي مطلوب',
          'inspector': 'م. ليلى',
          'contact': 'أ. محمود — مدير المدرسة',
          'city': 'خان يونس، شارع البحر',
          'city_name': 'خان يونس',
          'address': 'شارع البحر',
          'contact_name': 'أ. محمود',
          'contact_title': 'مدير المدرسة',
          'email': 'nour@school.ps',
          'phone': '',
          'note': '',
          'pre_inspection_requested': true,
        });
        final client = result.getOrElse(() => throw StateError('no client'));
        expect(
          (
            client.id,
            client.name,
            client.stage,
            client.city,
            client.compliance,
          ),
          (
            'doc-1',
            'مدرسة النور',
            ClientStage.inspection,
            'خان يونس، شارع البحر',
            null,
          ),
        );
        final all = (await repository.getClients()).getOrElse(() => []);
        expect(all.length, 9);
        expect(all.last.name, 'مدرسة النور');
      },
    );

    test('a refused write becomes a ForbiddenFailure', () async {
      final remote = FakeClientsRemoteDataSource();
      final repository = ClientsRepositoryImpl(remote);
      remote.error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );

      expect(
        await repository.addClient(_school),
        const Left<Failure, Client>(ForbiddenFailure()),
      );
    });
  });
}
