import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/overview_records.dart';

/// The records the overview summarises, from Firebase. Throws Firestore's
/// own exceptions; the repository maps them.
abstract interface class OverviewRemoteDataSource {
  Future<List<OverviewClient>> getClients();

  /// Visits dated [from] to [to] (`yyyy-MM-dd`, both included).
  Future<List<OverviewVisit>> getVisits({
    required String from,
    required String to,
  });

  Future<List<OverviewRisk>> getRisks();

  Future<List<OverviewAction>> getActions();
}

/// Reads `clients`, `visits`, `risks` and `corrective_actions`.
class FirestoreOverviewDataSource implements OverviewRemoteDataSource {
  static const clientsCollection = 'clients';
  static const visitsCollection = 'visits';
  static const risksCollection = 'risks';
  static const actionsCollection = 'corrective_actions';

  final FirebaseFirestore _firestore;

  FirestoreOverviewDataSource(this._firestore);

  @override
  Future<List<OverviewClient>> getClients() async => [
    for (final doc in (await _all(clientsCollection)).docs)
      ?OverviewClient.fromDocument(doc.data()),
  ];

  @override
  Future<List<OverviewVisit>> getVisits({
    required String from,
    required String to,
  }) async {
    // A range on a single field needs no composite index.
    final snapshot = await _firestore
        .collection(visitsCollection)
        .where('date', isGreaterThanOrEqualTo: from)
        .where('date', isLessThanOrEqualTo: to)
        .get();
    return [
      for (final doc in snapshot.docs) ?OverviewVisit.fromDocument(doc.data()),
    ];
  }

  @override
  Future<List<OverviewRisk>> getRisks() async => [
    for (final doc in (await _all(risksCollection)).docs)
      ?OverviewRisk.fromDocument(doc.data()),
  ];

  @override
  Future<List<OverviewAction>> getActions() async => [
    for (final doc in (await _all(actionsCollection)).docs)
      ?OverviewAction.fromDocument(doc.data()),
  ];

  Future<QuerySnapshot<Map<String, dynamic>>> _all(String collection) =>
      _firestore.collection(collection).get();
}
