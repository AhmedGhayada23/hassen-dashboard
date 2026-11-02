import 'package:hassen_dashboard/features/dashboard_risks/data/datasources/risks_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_risks/data/models/risk_model.dart';

import '../fixtures/risks_fixture.dart';

/// In-memory stand-in for the Firestore `risks` collection, seeded with the
/// original seven risks (in the order they were added). Throws [error] when
/// set.
class FakeRisksRemoteDataSource implements RisksRemoteDataSource {
  Map<String, Map<String, Object?>> documents = riskDocuments();
  Object? error;

  @override
  Future<List<RiskModel>> getRisks() async {
    if (error case final e?) throw e;
    return [
      for (final MapEntry(:key, :value) in documents.entries)
        ?RiskModel.fromDocument(key, value),
    ];
  }
}
