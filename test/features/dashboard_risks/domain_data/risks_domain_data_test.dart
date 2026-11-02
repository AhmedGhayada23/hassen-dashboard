import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/core/usecases/usecase.dart';
import 'package:hassen_dashboard/features/dashboard_risks/data/models/risk_model.dart';
import 'package:hassen_dashboard/features/dashboard_risks/data/repositories/risks_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk_level.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk_matrix.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/entities/risk_status.dart';
import 'package:hassen_dashboard/features/dashboard_risks/domain/usecases/get_risks.dart';

import '../fixtures/risks_fixture.dart';
import '../helpers/fake_risks_remote_datasource.dart';

Map<String, Object?> _json({num likelihood = 3, num severity = 3}) => {
  ...riskDocuments().values.first,
  'likelihood': likelihood,
  'severity': severity,
};

void main() {
  test('1. score = likelihood × severity', () {
    expect([for (final r in expectedRisks) r.score], [20, 15, 12, 10, 9, 4, 6]);
  });

  test('2. scores band into the four levels at 5, 10 and 15', () {
    expect(
      {for (var s = 1; s <= 25; s++) s: RiskLevel.fromScore(s)}.entries
          .where((e) => const [4, 5, 9, 10, 14, 15, 25].contains(e.key))
          .map((e) => (e.key, e.value)),
      [
        (4, RiskLevel.low),
        (5, RiskLevel.medium),
        (9, RiskLevel.medium),
        (10, RiskLevel.high),
        (14, RiskLevel.high),
        (15, RiskLevel.critical),
        (25, RiskLevel.critical),
      ],
    );
    expect(
      [for (final r in expectedRisks) r.level],
      [
        RiskLevel.critical,
        RiskLevel.critical,
        RiskLevel.high,
        RiskLevel.high,
        RiskLevel.medium,
        RiskLevel.low,
        RiskLevel.medium,
      ],
    );
  });

  group('3. ratings outside 1–5 are rejected', () {
    test('by the domain rule and the entity assertion', () {
      expect(
        [
          for (final v in [0, 1, 5, 6]) Risk.isValidRating(v),
        ],
        [false, true, true, false],
      );
      expect(
        () => Risk(
          id: 'x',
          hazard: 'h',
          facility: 'f',
          likelihood: 6,
          severity: 1,
          owner: 'o',
          status: RiskStatus.open,
          control: 'c',
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('by the model: such a document is left out, not fatal', () async {
      expect(RiskModel.fromDocument('x', _json(likelihood: 0)), isNull);
      expect(RiskModel.fromDocument('x', _json(severity: 6)), isNull);
      expect(RiskModel.fromDocument('x', _json(severity: 2.5)), isNull);
      expect(
        RiskModel.fromDocument('x', {..._json(), 'likelihood': '4'}),
        isNull,
      );
      expect(
        RiskModel.fromDocument(
          'x',
          _json(likelihood: 5, severity: 1),
        )?.likelihood,
        5,
      );
      // Firestore may hand back whole numbers as doubles.
      expect(RiskModel.fromDocument('x', _json(severity: 4.0))?.severity, 4);

      final remote = FakeRisksRemoteDataSource()
        ..documents['RSK-BAD'] = _json(severity: 9);
      final risks = (await RisksRepositoryImpl(
        remote,
      ).getRisks()).getOrElse(() => []);
      expect(risks, expectedRisks);
    });
  });

  group('4. Firestore documents', () {
    test('load as the seven original risks, in the order added', () async {
      final result = await RisksRepositoryImpl(
        FakeRisksRemoteDataSource(),
      ).getRisks();

      expect(result.getOrElse(() => []), expectedRisks);
    });

    test('a sparse or hand-edited document reads safely', () {
      final model = RiskModel.fromDocument('RSK-9', const {
        'hazard': '  سقوط أجسام  ',
        'likelihood': 2,
        'severity': 4,
        'status': 'closed',
      })!;

      expect(
        (
          model.id,
          model.hazard,
          model.facility,
          model.owner,
          model.control,
          model.status,
        ),
        ('RSK-9', 'سقوط أجسام', '—', '—', '—', RiskStatus.open),
      );
      expect(RiskModel.fromDocument('x', const {'likelihood': 1}), isNull);
    });

    test('Firestore errors become failures the page can explain', () async {
      final remote = FakeRisksRemoteDataSource();
      Future<Failure> failureFor(String code) async {
        remote.error = FirebaseException(plugin: 'cloud_firestore', code: code);
        return (await RisksRepositoryImpl(
          remote,
        ).getRisks()).fold((f) => f, (_) => throw StateError('no failure'));
      }

      expect(await failureFor('permission-denied'), const ForbiddenFailure());
      expect(await failureFor('unavailable'), const NetworkFailure());
      expect(await failureFor('internal'), isA<UnknownFailure>());
    });

    test('the register lists the highest score first', () async {
      final risks = (await GetRisks(
        RisksRepositoryImpl(FakeRisksRemoteDataSource()),
      )(const NoParams())).getOrElse(() => []);

      expect([for (final r in risks) r.score], [20, 15, 12, 10, 9, 6, 4]);
      expect(risks.map((r) => r.id).skip(5), ['RSK-007', 'RSK-006']);
    });
  });

  group('matrix', () {
    final matrix = RiskMatrix.fromRisks(expectedRisks);

    test('5. counts the risks in each likelihood × severity cell', () {
      final occupied = {
        for (final cell in matrix.rows.expand((r) => r))
          if (!cell.isEmpty) (cell.likelihood, cell.severity): cell.count,
      };
      expect(occupied, {
        (4, 5): 1,
        (3, 5): 1,
        (3, 4): 1,
        (2, 5): 1,
        (3, 3): 1,
        (2, 2): 1,
        (2, 3): 1,
      });
      expect(matrix.countAt(likelihood: 1, severity: 1), 0);
    });

    test('6. cell counts add up to the number of risks', () {
      expect(matrix.total, expectedRisks.length);
      final doubled = RiskMatrix.fromRisks([
        ...expectedRisks,
        expectedRisks.first,
      ]);
      expect(
        (doubled.total, doubled.countAt(likelihood: 4, severity: 5)),
        (8, 2),
      );
    });

    test(
      'rows run likelihood 5 → 1, columns severity 1 → 5, each cell scored',
      () {
        expect(matrix.rows.map((r) => r.first.likelihood), [5, 4, 3, 2, 1]);
        expect(matrix.rows.first.map((c) => c.severity), [1, 2, 3, 4, 5]);
        expect(matrix.rows.first.last.level, RiskLevel.critical); // 5 × 5
        expect(matrix.rows.last.first.level, RiskLevel.low); // 1 × 1
        expect(RiskMatrix.fromRisks(const []).total, 0);
      },
    );
  });
}
