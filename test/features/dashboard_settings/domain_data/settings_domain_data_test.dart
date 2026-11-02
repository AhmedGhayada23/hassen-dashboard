import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/exceptions.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/dashboard_settings/data/datasources/settings_local_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_settings/data/repositories/settings_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/entities/system_role.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/usecases/get_inspection_templates.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/usecases/get_operation_rules.dart';
import 'package:hassen_dashboard/features/dashboard_settings/domain/usecases/get_system_roles.dart';

import '../fixtures/settings_fixture.dart';

void main() {
  const repository = SettingsRepositoryImpl(SettingsLocalDataSource());

  group('use cases over the demo data', () {
    test('the five inspection templates: names, versions, items', () async {
      final templates = (await GetInspectionTemplates(repository)(
        const NoParams(),
      )).getOrElse(() => []);

      expect(templates, expectedTemplates);
      expect(
        [for (final t in templates) (t.version, t.items)],
        [('v2', 38), ('v3', 42), ('v1', 28), ('v1', 23), ('v2', 30)],
      );
    });

    test('the seven roles in order, with users and organization', () async {
      final roles = (await GetSystemRoles(repository)(
        const NoParams(),
      )).getOrElse(() => []);

      expect(roles, expectedRoles);
      expect([for (final r in roles) r.usersCount], [1, 1, 1, 4, 1, 5, 7]);
      expect(
        [for (final r in roles) r.organization == RoleOrganization.haseen],
        [true, true, true, true, true, false, false],
      );
    });

    test('the seven operating rules with their values', () async {
      final rules = (await GetOperationRules(repository)(
        const NoParams(),
      )).getOrElse(() => []);

      expect(rules, expectedRules);
    });
  });

  group('malformed data', () {
    test('throws ParseException from the data source', () {
      expect(
        const SettingsLocalDataSource(
          templatesJson: [
            {'name': 'x', 'version': 'v1', 'items': 0},
          ],
        ).getInspectionTemplates(),
        throwsA(isA<ParseException>()),
      );
      expect(
        const SettingsLocalDataSource(
          rolesJson: [
            {'name': 'x', 'users': 1, 'organization': 'other'},
          ],
        ).getSystemRoles(),
        throwsA(isA<ParseException>()),
      );
      expect(
        const SettingsLocalDataSource(
          rolesJson: [
            {'name': 'x', 'users': -1, 'organization': 'haseen'},
          ],
        ).getSystemRoles(),
        throwsA(isA<ParseException>()),
      );
      expect(
        const SettingsLocalDataSource(
          rulesJson: [
            {'title': 'x'},
          ],
        ).getOperationRules(),
        throwsA(isA<ParseException>()),
      );
    });

    test('becomes a failure in the repository, not a crash', () async {
      final broken = SettingsRepositoryImpl(
        const SettingsLocalDataSource(
          rulesJson: [
            {'value': 'no title'},
          ],
        ),
      );

      expect(
        (await broken.getOperationRules()).fold((f) => f, (_) => null),
        isA<CacheFailure>(),
      );
    });
  });
}
