import 'package:hassen_dashboard/core/errors/exceptions.dart';
import 'package:hassen_dashboard/features/dashboard_actions/data/datasources/corrective_actions_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_actions/data/models/corrective_action_model.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';

import '../fixtures/actions_fixture.dart';

/// [expectedActions] as Firestore `corrective_actions` documents, keyed by
/// document id, in board order.
Map<String, Map<String, Object?>> actionDocuments() => {
  for (final a in expectedActions)
    a.id: {
      'title': a.title,
      'facility': a.facility,
      'severity': a.severity.name,
      'owner': a.owner,
      'due_text': a.dueText,
      'due_status': a.dueStatus.name,
      'status': CorrectiveActionModel.statusToJson(a.status),
    },
};

/// In-memory stand-in for the Firestore `corrective_actions` collection,
/// seeded with the original nine actions. Applies status updates; throws
/// [error] when set.
class FakeCorrectiveActionsRemoteDataSource
    implements CorrectiveActionsRemoteDataSource {
  Map<String, Map<String, Object?>> documents = actionDocuments();
  Object? error;

  @override
  Future<List<CorrectiveActionModel>> getActions() async {
    if (error case final e?) throw e;
    return [
      for (final MapEntry(:key, :value) in documents.entries)
        ?CorrectiveActionModel.fromDocument(key, value),
    ];
  }

  @override
  Future<CorrectiveActionModel> updateStatus(
    String id,
    ActionStatus status,
  ) async {
    if (error case final e?) throw e;
    final doc = documents[id];
    if (doc == null) throw NotFoundException(message: 'No action $id.');
    doc['status'] = CorrectiveActionModel.statusToJson(status);
    return CorrectiveActionModel.fromDocument(id, doc)!;
  }
}
