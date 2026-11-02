import 'package:hassen_dashboard/features/dashboard_contracts/data/datasources/contracts_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_contracts/data/models/deal_model.dart';

import '../fixtures/contracts_fixture.dart';

/// In-memory stand-in for the Firestore `clients` collection, seeded with
/// the original screen's clients. Applies and records every update; throws
/// [error] when set.
class FakeContractsRemoteDataSource implements ContractsRemoteDataSource {
  final List<ClientRecord> clients = clientRecords();
  final updates = <(String, Map<String, Object?>)>[];
  Object? error;

  @override
  Future<List<DealModel>> getDeals() async {
    if (error case final e?) throw e;
    return DealModel.fromClients(clients, currentYear: 2026);
  }

  @override
  Future<void> updateDeal(String id, Map<String, Object?> changes) async {
    if (error case final e?) throw e;
    updates.add((id, changes));
    final i = clients.indexWhere((c) => c.id == id);
    final c = clients[i];
    clients[i] = (
      id: c.id,
      json: {...c.json, ...changes},
      createdAt: c.createdAt,
    );
  }
}
