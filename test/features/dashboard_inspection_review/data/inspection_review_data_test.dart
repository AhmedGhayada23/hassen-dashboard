import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/exceptions.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/data/datasources/inspection_review_local_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/data/models/finding_model.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/data/models/inspection_model.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/data/repositories/inspection_review_repository_impl.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/finding_severity.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection.dart';
import 'package:hassen_dashboard/features/dashboard_inspection_review/domain/entities/inspection_decision.dart';

import '../fixtures/inspections_fixture.dart';

void main() {
  group('models', () {
    test('FindingModel maps every severity code', () {
      FindingSeverity severityOf(String code) => FindingModel.fromJson({
        'title': 't',
        'severity': code,
        'note': 'n',
        'due': 'd',
      }).toEntity().severity;

      expect([
        for (final c in ['critical', 'high', 'medium', 'low']) severityOf(c),
      ], FindingSeverity.values);
      expect(() => severityOf('extreme'), throwsArgumentError);
    });

    test('InspectionModel keeps every field through model → entity', () {
      final json = InspectionReviewLocalDataSource.demoInspectionsJson.first;
      final entity = InspectionModel.fromJson(json).toEntity();

      expect(entity, expectedInspections.first);
      expect(entity.findings, hasLength(3));
      expect(entity.date, DateTime(2026, 10, 28));
    });

    test('decision defaults to pending and can be read from JSON', () {
      final json = Map.of(
        InspectionReviewLocalDataSource.demoInspectionsJson.last,
      );
      expect(
        InspectionModel.fromJson(json).decision,
        InspectionDecision.pending,
      );

      json['decision'] = 'returned';
      expect(
        InspectionModel.fromJson(json).decision,
        InspectionDecision.returned,
      );
    });
  });

  group('local data source', () {
    test('returns the four original reports exactly', () async {
      final models = await InspectionReviewLocalDataSource().getInspections();

      expect([for (final m in models) m.toEntity()], expectedInspections);
      expect([for (final m in models) m.findings.length], [3, 2, 2, 1]);
    });

    test('stores decisions in memory and clears them on reset', () async {
      final source = InspectionReviewLocalDataSource();

      final approved = await source.updateDecision(
        'INS-0417',
        InspectionDecision.approved,
      );
      expect(approved.decision, InspectionDecision.approved);
      expect(
        (await source.getInspections())[1].decision,
        InspectionDecision.approved,
      );

      await source.updateDecision('INS-0417', InspectionDecision.pending);
      expect(
        (await source.getInspections())[1].decision,
        InspectionDecision.pending,
      );
    });

    test('throws NotFoundException for an unknown report', () {
      expect(
        InspectionReviewLocalDataSource().updateDecision(
          'INS-9999',
          InspectionDecision.approved,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('throws ParseException on a malformed payload', () {
      expect(
        InspectionReviewLocalDataSource(
          json: const [
            {'id': 1},
          ],
        ).getInspections(),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('repository', () {
    test('returns entities and updated reports', () async {
      final repository = InspectionReviewRepositoryImpl(
        InspectionReviewLocalDataSource(),
      );

      expect(
        await repository.getInspections(),
        isA<Right<Failure, List<Inspection>>>(),
      );
      final updated = await repository.updateDecision(
        'INS-0415',
        InspectionDecision.returned,
      );
      updated.fold(
        (_) => fail('expected success'),
        (i) => expect(i.decision, InspectionDecision.returned),
      );
    });

    test(
      'maps an unknown report to NotFoundFailure and bad data to CacheFailure',
      () async {
        final missing = await InspectionReviewRepositoryImpl(
          InspectionReviewLocalDataSource(),
        ).updateDecision('INS-9999', InspectionDecision.approved);
        missing.fold(
          (f) => expect(f, isA<NotFoundFailure>()),
          (_) => fail('expected failure'),
        );

        final broken = await InspectionReviewRepositoryImpl(
          InspectionReviewLocalDataSource(
            json: const [
              {'id': 1},
            ],
          ),
        ).getInspections();
        broken.fold(
          (f) => expect(f, isA<CacheFailure>()),
          (_) => fail('expected failure'),
        );
      },
    );
  });
}
