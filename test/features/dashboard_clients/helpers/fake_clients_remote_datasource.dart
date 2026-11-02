import 'package:hassen_dashboard/features/dashboard_clients/data/datasources/clients_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_clients/data/models/client_model.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_registration_options.dart';

import '../fixtures/clients_fixture.dart';

/// In-memory stand-in for Firebase, seeded with the original eight clients,
/// sectors and inspectors. Keeps the documents it is given; throws [error]
/// when set.
class FakeClientsRemoteDataSource implements ClientsRemoteDataSource {
  List<ClientModel> clients = [
    for (final c in expectedClients)
      ClientModel(
        id: c.id,
        name: c.name,
        type: c.type,
        branches: c.branches,
        stage: c.stage,
        openFindings: c.openFindings,
        compliance: c.compliance,
        contract: c.contract,
        visits: c.visits,
        inspector: c.inspector,
        contact: c.contact,
        city: c.city,
      ),
  ];
  List<String> sectors = [...expectedRegistrationOptions.sectors];
  List<InspectorLoad> inspectors = [...expectedRegistrationOptions.inspectors];
  final documents = <Map<String, Object?>>[];
  Object? error;
  int calls = 0;

  @override
  Future<List<ClientModel>> getClients() async {
    if (error case final e?) throw e;
    return [...clients];
  }

  @override
  Future<ClientModel> addClient(Map<String, Object?> document) async {
    if (error case final e?) throw e;
    documents.add(document);
    final stored = ClientModel.fromDocument(
      'doc-${documents.length}',
      document,
    );
    clients = [...clients, stored];
    return stored;
  }

  @override
  Future<List<String>> getSectors() async {
    if (error case final e?) throw e;
    return [...sectors];
  }

  @override
  Future<List<InspectorLoad>> getInspectors() async {
    calls++;
    if (error case final e?) throw e;
    return [...inspectors];
  }
}
