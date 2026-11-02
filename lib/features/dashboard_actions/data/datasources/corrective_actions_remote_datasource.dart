import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/action_status.dart';
import '../models/corrective_action_model.dart';

/// The corrective actions, in Firebase. Throws Firestore's own exceptions;
/// the repository maps them.
abstract interface class CorrectiveActionsRemoteDataSource {
  /// Every readable action, in the order they were added.
  Future<List<CorrectiveActionModel>> getActions();

  /// Moves action [id] to [status] and returns it as stored.
  /// Throws [NotFoundException] for an unknown [id].
  Future<CorrectiveActionModel> updateStatus(String id, ActionStatus status);
}

/// Reads and updates the Firestore `corrective_actions` collection (see
/// [CorrectiveActionModel]).
class FirestoreCorrectiveActionsDataSource
    implements CorrectiveActionsRemoteDataSource {
  static const actionsCollection = 'corrective_actions';

  final FirebaseFirestore _firestore;

  FirestoreCorrectiveActionsDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _actions =>
      _firestore.collection(actionsCollection);

  @override
  Future<List<CorrectiveActionModel>> getActions() async {
    final snapshot = await _actions.get();
    // Oldest first, then by id; sorted here, so the query needs no index.
    // Documents without a timestamp come after the rest.
    int at(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
        (doc.data()['created_at'] as Timestamp?)?.millisecondsSinceEpoch ??
        double.maxFinite.toInt();
    final docs = snapshot.docs.toList()
      ..sort((a, b) {
        final byTime = at(a).compareTo(at(b));
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    return [
      for (final doc in docs)
        ?CorrectiveActionModel.fromDocument(doc.id, doc.data()),
    ];
  }

  @override
  Future<CorrectiveActionModel> updateStatus(
    String id,
    ActionStatus status,
  ) async {
    final ref = _actions.doc(id);
    try {
      await ref.update({
        'status': CorrectiveActionModel.statusToJson(status),
        'status_updated_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw NotFoundException(message: 'Corrective action $id not found.');
      }
      rethrow;
    }
    final model = CorrectiveActionModel.fromDocument(
      id,
      (await ref.get()).data() ?? const {},
    );
    if (model == null) {
      throw NotFoundException(message: 'Corrective action $id not found.');
    }
    return model;
  }
}
