import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/client_registration_options.dart';
import '../models/client_model.dart';

/// Clients and the "new client" form's choices, all in Firebase. Throws
/// Firestore's own exceptions; the repository maps them.
abstract interface class ClientsRemoteDataSource {
  /// Every document in `clients`, in the order they were added.
  Future<List<ClientModel>> getClients();

  /// Stores [document] in `clients` and returns the stored client.
  Future<ClientModel> addClient(Map<String, Object?> document);

  /// The `sectors` names, by `order`.
  Future<List<String>> getSectors();

  /// The safety inspectors in `users`, in the order they were added.
  Future<List<InspectorLoad>> getInspectors();
}

/// Firestore collections:
/// * `clients` — one document per client (see [ClientModel]).
/// * `sectors` — `name`, and `order` for the picker.
/// * `users` — inspectors are the documents whose `role` is [inspectorRole];
///   `name` is shown and `weekly_visits` (optional, 0 when missing) drives
///   the suggestion.
class FirestoreClientsDataSource implements ClientsRemoteDataSource {
  static const clientsCollection = 'clients';
  static const sectorsCollection = 'sectors';
  static const usersCollection = 'users';
  static const inspectorRole = 'inspector';

  final FirebaseFirestore _firestore;

  FirestoreClientsDataSource(this._firestore);

  @override
  Future<List<ClientModel>> getClients() async {
    final snapshot = await _firestore.collection(clientsCollection).get();
    final docs = snapshot.docs.toList()
      ..sort((a, b) => _createdAt(a).compareTo(_createdAt(b)));
    return [
      for (final doc in docs)
        if ((doc.data()['name'] as String? ?? '').trim().isNotEmpty)
          ClientModel.fromDocument(doc.id, doc.data()),
    ];
  }

  @override
  Future<ClientModel> addClient(Map<String, Object?> document) async {
    final ref = await _firestore.collection(clientsCollection).add({
      ...document,
      'created_at': FieldValue.serverTimestamp(),
    });
    return ClientModel.fromDocument(ref.id, document);
  }

  @override
  Future<List<String>> getSectors() async {
    final snapshot = await _firestore.collection(sectorsCollection).get();
    final docs = snapshot.docs.toList()
      ..sort((a, b) => _order(a).compareTo(_order(b)));
    return [
      for (final doc in docs)
        if ((doc.data()['name'] as String? ?? '').trim().isNotEmpty)
          (doc.data()['name'] as String).trim(),
    ];
  }

  @override
  Future<List<InspectorLoad>> getInspectors() async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: inspectorRole)
        .get();
    final docs = snapshot.docs.toList()
      // Sorted here, so the query needs no composite index.
      ..sort((a, b) => _createdAt(a).compareTo(_createdAt(b)));
    return [
      for (final doc in docs)
        if ((doc.data()['name'] as String? ?? '').trim().isNotEmpty)
          InspectorLoad(
            name: (doc.data()['name'] as String).trim(),
            weeklyVisits: (doc.data()['weekly_visits'] as num?)?.toInt() ?? 0,
          ),
    ];
  }

  /// Creation time in ms; documents without one (just written) sort last.
  static int _createdAt(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      (doc.data()['created_at'] as Timestamp?)?.millisecondsSinceEpoch ??
      double.maxFinite.toInt();

  static int _order(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      (doc.data()['order'] as num?)?.toInt() ?? 0;
}
