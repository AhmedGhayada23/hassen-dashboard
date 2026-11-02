import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_team/data/models/team_member_model.dart';
import 'package:hassen_dashboard/features/dashboard_team/data/repositories/team_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/team_member.dart';
import 'package:hassen_dashboard/features/dashboard_team/domain/entities/team_summary.dart';

import '../fixtures/team_fixture.dart';
import '../helpers/fake_team_remote_datasource.dart';

void main() {
  test('1–3. the roster is exactly the employees read from users', () async {
    final remote = FakeTeamRemoteDataSource()
      ..employees.addAll([
        TeamMemberModel.fromUserDocument('uid-1', {
          'name': 'م. أحمد',
          'role_name': 'مفتش سلامة',
          'facilities': 2,
          'monthly_visits': 18,
          'late_visits': 1,
          'workload': 85,
        }),
        TeamMemberModel.fromUserDocument('uid-2', {
          'name': 'رنا',
          'role_name': 'مدير العمليات',
        }),
      ]);

    final result = await TeamRepositoryImpl(remote).getTeamMembers();
    final members = result.getOrElse(() => []);

    expect(members.map((m) => (m.id, m.name)), [
      ('uid-1', 'م. أحمد'),
      ('uid-2', 'رنا'),
    ]);
    expect(
      members.map(
        (m) => (m.facilities, m.monthlyVisits, m.lateVisits, m.workload),
      ),
      [(2, 18, 1, 85), (0, 0, 0, 0)],
    );
  });

  test(
    'an empty users collection gives an empty roster, not an error',
    () async {
      final result = await TeamRepositoryImpl(
        FakeTeamRemoteDataSource(),
      ).getTeamMembers();

      expect(result.getOrElse(() => [expectedTeam.first]), isEmpty);
    },
  );

  test('4. initials drop the "م. " title only when present', () {
    expect(expectedTeam.map((m) => m.initial), ['أ', 'س', 'خ', 'ل', 'م', 'م']);
  });

  group('5–7. workload', () {
    test('only strictly above 80% is overloaded', () {
      expect(expectedTeam.first.isOverloaded, isTrue, reason: '85%');
      expect(
        memberAtThreshold.isOverloaded,
        isFalse,
        reason: 'exactly 80% is not over',
      );
      expect(expectedTeam.where((m) => m.isOverloaded).map((m) => m.name), [
        'م. أحمد',
      ]);
    });

    test('late visits are flagged when above zero', () {
      expect(expectedTeam.map((m) => m.hasLateVisits), [
        true,
        false,
        true,
        false,
        false,
        false,
      ]);
    });
  });

  group('8. value bounds', () {
    test('domain rules and entity assertions', () {
      expect(
        [
          for (final v in [-1, 0, 5]) TeamMember.isValidCount(v),
        ],
        [false, true, true],
      );
      expect(
        [
          for (final v in [-1, 0, 100, 101]) TeamMember.isValidWorkload(v),
        ],
        [false, true, true, false],
      );
      expect(
        () => TeamMember(
          id: 'x',
          name: 'n',
          role: 'r',
          facilities: 0,
          monthlyVisits: 0,
          lateVisits: -1,
          workload: 50,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TeamMember(
          id: 'x',
          name: 'n',
          role: 'r',
          facilities: 0,
          monthlyVisits: 0,
          lateVisits: 0,
          workload: 101,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
      'figures typed out of range in users are clamped, never break the page',
      () {
        final member = TeamMemberModel.fromUserDocument('uid-1', {
          'name': 'n',
          'facilities': -1,
          'monthly_visits': -2,
          'late_visits': 3.0,
          'workload': 120,
        }).toEntity();

        expect(
          (
            member.facilities,
            member.monthlyVisits,
            member.lateVisits,
            member.workload,
          ),
          (0, 0, 3, 100),
        );
      },
    );

    test(
      'roles come from Firestore, and a refused read is a ForbiddenFailure',
      () async {
        final remote = FakeTeamRemoteDataSource();
        final repository = TeamRepositoryImpl(remote);

        expect(
          (await repository.getEmployeeRoles()).getOrElse(() => []),
          expectedRoles,
        );

        remote.error = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        );
        (await repository.getEmployeeRoles()).fold(
          (f) => expect(f, const ForbiddenFailure()),
          (_) => fail('expected failure'),
        );
      },
    );
  });

  test('9. summary totals the team', () {
    expect(
      TeamSummary.fromMembers(expectedTeam),
      const TeamSummary(
        memberCount: 6,
        monthlyVisits: 57,
        lateVisits: 2,
        overloadedCount: 1,
        averageWorkload: 63,
      ),
    );
    expect(
      TeamSummary.fromMembers(const []),
      const TeamSummary(
        memberCount: 0,
        monthlyVisits: 0,
        lateVisits: 0,
        overloadedCount: 0,
        averageWorkload: 0,
      ),
    );
  });
}
