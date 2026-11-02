import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_stage.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/new_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/add_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/get_client_registration_options.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/usecases/get_clients.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/cubits/add_client_form_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/cubits/dashboard_clients_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/cubits/dashboard_clients_state.dart';
import 'package:hassen_dashboard/features/dashboard_clients/presentation/validation/add_client_validator.dart';

import '../../fixtures/clients_fixture.dart';
import '../../helpers/fake_clients_repository.dart';

const _school = NewClient(
  name: 'مدرسة النور',
  sector: 'مؤسسة تعليمية',
  branches: 2,
  contactName: 'أ. محمود',
  stage: ClientStage.inspection,
);

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

  group('DashboardClientsCubit.addClient', () {
    test('the form options are fetched on demand, with a busy state', () async {
      await cubit.load();

      final pending = cubit.prepareNewClient();
      expect(loaded().isPreparingForm, isTrue);
      // A second press while loading is ignored.
      expect(await cubit.prepareNewClient(), isNull);

      expect(await pending, expectedRegistrationOptions);
      expect(loaded().isPreparingForm, isFalse);
      expect(loaded().formFailure, isNull);
    });

    test('a failed options fetch is reported and opens nothing', () async {
      await cubit.load();
      repository.optionsFailure = const ForbiddenFailure();

      expect(await cubit.prepareNewClient(), isNull);

      expect(loaded().formFailure, const ForbiddenFailure());
      expect(loaded().isPreparingForm, isFalse);
      expect(loaded().clients, expectedClients);
    });

    test(
      'a failed options fetch does not stop the page from loading',
      () async {
        repository.optionsFailure = const ForbiddenFailure();

        await cubit.load();

        expect(cubit.state, isA<DashboardClientsLoaded>());
      },
    );

    test(
      'a new client is appended, selected under "الكل" and reported once',
      () async {
        await cubit.load();
        cubit.selectStage(ClientStage.contracted);

        await cubit.addClient(_school);

        final state = loaded();
        expect(state.clients.length, 9);
        expect(state.stageFilter, isNull);
        expect(state.selectedClient?.name, 'مدرسة النور');
        expect(state.lastAdded?.client, state.clients.last);
        expect(state.lastAdded?.schedulePreInspection, isTrue);
        expect(state.summary.countFor(ClientStage.inspection), 2);
      },
    );

    test('filtering after adding drops the outcome', () async {
      await cubit.load();
      await cubit.addClient(_school);

      cubit.selectStage(ClientStage.inspection);

      expect(loaded().lastAdded, isNull);
      expect(loaded().visibleClients.map((c) => c.name), [
        'مدرسة خاصة — غزة',
        'مدرسة النور',
      ]);
    });

    test(
      'a failed registration keeps the list and reports the failure',
      () async {
        await cubit.load();
        repository.addFailure = const CacheFailure();

        await cubit.addClient(_school);

        expect(loaded().clients, expectedClients);
        expect(loaded().actionFailure, const CacheFailure());
      },
    );

    test('is ignored before the clients have loaded', () async {
      await cubit.addClient(_school);

      expect(cubit.state, const DashboardClientsInitial());
      expect(repository.added, isEmpty);
    });
  });

  group('AddClientFormCubit', () {
    test('opens with no sector, "محتمل", unassigned and pre-inspection on', () {
      final form = AddClientFormCubit(expectedRegistrationOptions);
      addTearDown(form.close);

      expect(form.state, const AddClientFormState());
      expect(
        (
          form.state.sector,
          form.state.stage,
          form.state.inspector,
          form.state.schedulePreInspection,
        ),
        (null, ClientStage.potential, '', true),
      );
    });

    test('records each choice; "اختيار المقترح" picks the least loaded', () {
      final form = AddClientFormCubit(expectedRegistrationOptions);
      addTearDown(form.close);

      form
        ..selectSector('منشأة صحية')
        ..selectStage(ClientStage.quotation)
        ..assignSuggestedInspector()
        ..setSchedulePreInspection(false);

      expect(
        form.state,
        const AddClientFormState(
          sector: 'منشأة صحية',
          stage: ClientStage.quotation,
          inspector: 'م. ليلى',
          schedulePreInspection: false,
        ),
      );
      form.selectInspector('');
      expect(form.state.inspector, '');
    });
  });

  group('AddClientValidator (the original rules)', () {
    test('name is required and must not be registered already', () {
      expect(AddClientValidator.name(' ', {}), 'أدخل اسم المنشأة');
      expect(
        AddClientValidator.name(' بلدية غزة ', {'بلدية غزة'}),
        'هذه المنشأة مسجلة مسبقاً',
      );
      expect(AddClientValidator.name('مدرسة النور', {'بلدية غزة'}), isNull);
    });

    test('sector is required; branches is a whole number of at least 1', () {
      expect(AddClientValidator.sector(null), 'اختر القطاع');
      expect(AddClientValidator.sector('أخرى'), isNull);
      for (final bad in ['', '0', '-2', 'abc', '1.5']) {
        expect(
          AddClientValidator.branches(bad),
          'أدخل عدداً صحيحاً',
          reason: bad,
        );
      }
      expect(AddClientValidator.branches(' 3 '), isNull);
    });

    test('contact name is required', () {
      expect(AddClientValidator.contactName(''), 'أدخل اسم جهة التواصل');
      expect(AddClientValidator.contactName('أ. محمود'), isNull);
    });

    test('email or phone is required; each is checked when given', () {
      expect(
        AddClientValidator.email('', phone: ''),
        'أدخل البريد أو رقم الهاتف',
      );
      expect(AddClientValidator.email('', phone: '0599123456'), isNull);
      expect(
        AddClientValidator.email('a@b', phone: ''),
        'صيغة البريد غير صحيحة',
      );
      expect(AddClientValidator.email('a@b.ps', phone: ''), isNull);
      expect(AddClientValidator.phone(''), isNull);
      expect(AddClientValidator.phone('+970 599 123456'), isNull);
      expect(AddClientValidator.phone('0599-123'), 'رقم الهاتف غير صحيح');
    });
  });
}
