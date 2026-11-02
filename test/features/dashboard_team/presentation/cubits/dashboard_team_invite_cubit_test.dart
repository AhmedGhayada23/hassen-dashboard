import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/new_employee.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/add_employee.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/get_employee_roles.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/get_team_members.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/cubits/dashboard_team_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/cubits/dashboard_team_state.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/cubits/employee_role_cubit.dart';
import 'package:hassen_dashboard/features/dashboard_team/presentation/validation/add_employee_validator.dart';

import '../../fixtures/team_fixture.dart';
import '../../helpers/fake_team_repository.dart';

void main() {
  late FakeTeamRepository repository;
  late DashboardTeamCubit cubit;
  final employee = NewEmployee(
    fullName: 'سامي',
    email: ' sami@haseen.ps ',
    role: expectedRoles.first,
  );

  setUp(() {
    repository = FakeTeamRepository();
    cubit = DashboardTeamCubit(
      GetTeamMembers(repository),
      GetEmployeeRoles(repository),
      AddEmployee(repository),
    );
  });
  tearDown(() => cubit.close());

  test('loads the roles alongside the roster', () async {
    await cubit.load();

    expect(cubit.state, DashboardTeamLoaded(expectedTeam, expectedRoles));
  });

  test('fails to load when the roles cannot be read', () async {
    repository.rolesFailure = const CacheFailure();

    await cubit.load();

    expect(cubit.state, const DashboardTeamFailure(CacheFailure()));
  });

  test(
    'a new employee is appended with a temporary password and reported once',
    () async {
      await cubit.load();

      await cubit.addEmployee(employee);

      final state = cubit.state as DashboardTeamLoaded;
      expect(state.members.length, 7);
      final added = state.members.last;
      expect((added.name, added.isPendingActivation), ('م. سامي', true));
      expect(added.temporaryPassword, repository.passwords.single);
      expect(added.temporaryPassword, hasLength(10));
      expect(state.lastAdded, added);
      expect(state.isAdding, isFalse);
      expect(state.summary.memberCount, 7);
    },
  );

  test('shows the spinner state while the account is created', () async {
    await cubit.load();
    repository.gate = null;
    final pending = cubit.addEmployee(employee);

    expect((cubit.state as DashboardTeamLoaded).isAdding, isTrue);
    // A second request while one is running is ignored.
    await cubit.addEmployee(employee);
    await pending;

    expect(repository.added, hasLength(1));
    expect((cubit.state as DashboardTeamLoaded).isAdding, isFalse);
  });

  test('the password toggle reveals and masks one card at a time', () async {
    await cubit.load();
    await cubit.addEmployee(employee);
    final added = (cubit.state as DashboardTeamLoaded).members.last;
    bool revealed() =>
        (cubit.state as DashboardTeamLoaded).isPasswordRevealed(added);

    expect(revealed(), isFalse);
    cubit.togglePasswordVisibility(added);
    expect(revealed(), isTrue);
    expect(
      (cubit.state as DashboardTeamLoaded).isPasswordRevealed(
        expectedTeam.first,
      ),
      isFalse,
    );
    cubit.togglePasswordVisibility(added);
    expect(revealed(), isFalse);
  });

  test(
    'a failed invitation keeps the roster and reports the failure',
    () async {
      await cubit.load();
      repository.addFailure = const CacheFailure();

      await cubit.addEmployee(employee);

      expect(
        cubit.state,
        DashboardTeamLoaded(
          expectedTeam,
          expectedRoles,
          actionFailure: const CacheFailure(),
        ),
      );
    },
  );

  test('is ignored before the roster has loaded', () async {
    await cubit.addEmployee(employee);

    expect(cubit.state, const DashboardTeamInitial());
    expect(repository.added, isEmpty);
  });

  test('the role picker starts on the first role and switches', () async {
    final roles = EmployeeRoleCubit(expectedRoles);
    addTearDown(roles.close);

    expect(roles.state, expectedRoles.first);
    roles.select(expectedRoles[2]);
    expect(roles.state, expectedRoles[2]);
  });

  group('AddEmployeeValidator (the original rules)', () {
    test('name is required', () {
      expect(AddEmployeeValidator.fullName(' '), 'أدخل الاسم الكامل');
      expect(AddEmployeeValidator.fullName('سامي'), isNull);
    });

    test('email is required and must look like an address', () {
      expect(AddEmployeeValidator.email(''), 'أدخل البريد الإلكتروني');
      expect(
        AddEmployeeValidator.email('sami@haseen'),
        'صيغة البريد غير صحيحة',
      );
      expect(AddEmployeeValidator.email(' sami@haseen.ps '), isNull);
    });

    test('phone is optional; when given: 7–15 of digits, spaces and +', () {
      expect(AddEmployeeValidator.phone(''), isNull);
      expect(AddEmployeeValidator.phone('+970 599 123456'), isNull);
      for (final bad in [
        '123456',
        '05991234567890123',
        '0599-123456',
        'abc1234',
      ]) {
        expect(
          AddEmployeeValidator.phone(bad),
          'رقم الهاتف غير صحيح',
          reason: bad,
        );
      }
    });
  });
}
