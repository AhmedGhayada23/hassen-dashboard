import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/dashboard_team/data/models/employee_role_model.dart';
import 'package:hassen_dashboard/features/dashboard_team/data/models/team_member_model.dart';
import 'package:hassen_dashboard/features/dashboard_team/data/repositories/team_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/new_employee.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/team_member.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/temporary_password.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/failures/team_failures.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/add_employee.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/usecases/get_employee_roles.dart';

import '../fixtures/team_fixture.dart';
import '../helpers/fake_team_remote_datasource.dart';
import '../helpers/fake_team_repository.dart';

final _inspector = expectedRoles[0];
final _opsManager = expectedRoles[3];

void main() {
  group('NewEmployee', () {
    test('field roles get the engineer title; office roles do not', () {
      expect(
        NewEmployee(
          fullName: '  سامي  ',
          email: 'a@b.c',
          role: _inspector,
        ).displayName,
        'م. سامي',
      );
      expect(
        NewEmployee(
          fullName: 'رنا',
          email: 'a@b.c',
          role: _opsManager,
        ).displayName,
        'رنا',
      );
    });

    test('needs a name and an email', () {
      expect(
        NewEmployee(fullName: ' ', email: 'a@b.c', role: _inspector).isComplete,
        isFalse,
      );
      expect(
        NewEmployee(fullName: 'س', email: '', role: _inspector).isComplete,
        isFalse,
      );
      expect(
        NewEmployee(fullName: 'س', email: 'a@b.c', role: _inspector).isComplete,
        isTrue,
      );
    });
  });

  test('no role offered here is the dashboard admin role', () {
    expect(expectedRoles.map((r) => r.id), isNot(contains('admin')));
  });

  group('TemporaryPassword', () {
    test(
      'is 10 characters with upper, lower and a digit, and no look-alikes',
      () {
        for (var seed = 0; seed < 200; seed++) {
          final password = TemporaryPassword.generate(Random(seed));
          expect(password, hasLength(TemporaryPassword.length));
          expect(password, matches(RegExp('[A-Z]')), reason: password);
          expect(password, matches(RegExp('[a-z]')), reason: password);
          expect(password, matches(RegExp('[0-9]')), reason: password);
          expect(password, isNot(matches(RegExp('[0O1lI]'))), reason: password);
        }
      },
    );

    test('differs from one account to the next', () {
      final passwords = {
        for (var i = 0; i < 50; i++) TemporaryPassword.generate(),
      };
      expect(passwords, hasLength(50));
    });
  });

  group('use cases', () {
    test(
      'AddEmployee refuses an incomplete employee without storing it',
      () async {
        final repository = FakeTeamRepository();

        final result = await AddEmployee(repository)(
          NewEmployee(fullName: '', email: 'a@b.c', role: _inspector),
        );

        expect(result.isLeft(), isTrue);
        result.fold((f) => expect(f, isA<ValidationFailure>()), (_) {});
        expect(repository.added, isEmpty);
      },
    );

    test(
      'AddEmployee creates the account with a generated temporary password',
      () async {
        final repository = FakeTeamRepository();
        final employee = NewEmployee(
          fullName: 'سامي',
          email: 'sami@haseen.ps',
          role: _inspector,
        );

        final result = await AddEmployee(
          repository,
          generatePassword: () => 'Tmp4Pass9x',
        )(employee);

        expect(repository.added, [employee]);
        expect(repository.passwords, ['Tmp4Pass9x']);
        final member = result.getOrElse(() => throw StateError('no member'));
        expect(
          (member.name, member.temporaryPassword),
          ('م. سامي', 'Tmp4Pass9x'),
        );
        expect(
          await GetEmployeeRoles(repository)(const NoParams()),
          isA<Right<Failure, dynamic>>(),
        );
      },
    );
  });

  group('data', () {
    test('a roles document reads its fields, with safe defaults', () {
      final full = EmployeeRoleModel.fromDocument('inspector', {
        'name': 'مفتش سلامة',
        'description': 'ينفّذ الزيارات من التطبيق الميداني',
        'field': true,
        'order': 1,
      });
      expect(full.toEntity(), expectedRoles.first);
      expect(full.order, 1);

      final bare = EmployeeRoleModel.fromDocument('auditor', const {});
      expect(
        (bare.name, bare.description, bare.isFieldRole, bare.order),
        ('auditor', '', false, 0),
      );
    });

    test('a users document becomes a pending card with its password', () {
      final model = TeamMemberModel.fromUserDocument('uid-9', {
        'name': 'م. سامي',
        'email': 'sami@haseen.ps',
        'role': 'inspector',
        'role_name': 'مفتش سلامة',
        'pending_activation': true,
        'temporary_password': 'Tmp4Pass9x',
      });

      expect(
        model.toEntity(),
        const TeamMember(
          id: 'uid-9',
          name: 'م. سامي',
          role: 'مفتش سلامة',
          facilities: 0,
          monthlyVisits: 0,
          lateVisits: 0,
          workload: 0,
          isPendingActivation: true,
          temporaryPassword: 'Tmp4Pass9x',
        ),
      );
    });

    test('a sparse users document still reads safely', () {
      final member = TeamMemberModel.fromUserDocument('uid-1', const {
        'name': 'رنا',
        'role': 'operations_manager',
      }).toEntity();

      expect(
        (member.role, member.isPendingActivation, member.temporaryPassword),
        ('operations_manager', false, null),
      );
    });

    test(
      'an added employee is stored in users and read back into the roster',
      () async {
        final remote = FakeTeamRemoteDataSource();
        final repository = TeamRepositoryImpl(remote);

        final added = await repository.addEmployee(
          NewEmployee(
            fullName: ' سامي ',
            email: ' sami@haseen.ps ',
            phone: ' 0599 123456 ',
            role: _inspector,
          ),
          temporaryPassword: 'Tmp4Pass9x',
        );

        expect(remote.created.single, {
          'name': 'م. سامي',
          'email': 'sami@haseen.ps',
          'phone': '0599 123456',
          'role': 'inspector',
          'role_name': 'مفتش سلامة',
          'temporary_password': 'Tmp4Pass9x',
        });
        added.fold((_) => fail('expected success'), (m) {
          expect(
            (m.isPendingActivation, m.temporaryPassword),
            (true, 'Tmp4Pass9x'),
          );
        });
        final roster = (await repository.getTeamMembers()).getOrElse(() => []);
        expect(roster.map((m) => m.name), ['م. سامي']);
      },
    );

    test('Firebase errors map to failures the page can explain', () async {
      final remote = FakeTeamRemoteDataSource();
      final repository = TeamRepositoryImpl(remote);
      Future<Failure> failureFor(Object error) async {
        remote.error = error;
        final result = await repository.addEmployee(
          NewEmployee(fullName: 'س', email: 'a@b.c', role: _inspector),
          temporaryPassword: 'Tmp4Pass9x',
        );
        return result.fold((f) => f, (_) => throw StateError('no failure'));
      }

      expect(
        await failureFor(FirebaseAuthException(code: 'email-already-in-use')),
        const EmailAlreadyInUseFailure(),
      );
      expect(
        await failureFor(FirebaseAuthException(code: 'network-request-failed')),
        const NetworkFailure(),
      );
      expect(
        await failureFor(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
        const ForbiddenFailure(),
      );
      expect(
        await failureFor(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        ),
        const NetworkFailure(),
      );

      // A failing read of the Firebase employees fails the whole roster load.
      remote.error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      expect(
        await repository.getTeamMembers(),
        const Left<Failure, List<TeamMember>>(ForbiddenFailure()),
      );
    });
  });
}
