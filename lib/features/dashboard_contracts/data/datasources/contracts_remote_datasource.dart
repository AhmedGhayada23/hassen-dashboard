import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/deal_model.dart';

/// The clients' deals, kept on their Firestore `clients` documents (see
/// [DealModel]). Throws Firestore's own exceptions; the repository maps them.
abstract interface class ContractsRemoteDataSource {
  /// One deal per client, oldest client first.
  Future<List<DealModel>> getDeals();

  /// Applies [changes] (from [DealModel]'s builders) to client [id].
  Future<void> updateDeal(String id, Map<String, Object?> changes);
}

class FirestoreContractsDataSource implements ContractsRemoteDataSource {
  static const clientsCollection = 'clients';

  final FirebaseFirestore _firestore;
  final DateTime Function() _clock;

  FirestoreContractsDataSource(
    this._firestore, {
    DateTime Function() clock = DateTime.now,
  }) : _clock = clock;

  @override
  Future<List<DealModel>> getDeals() async {
    final snapshot = await _firestore.collection(clientsCollection).get();
    return DealModel.fromClients([
      for (final doc in snapshot.docs)
        (
          id: doc.id,
          json: doc.data(),
          createdAt: (doc.data()['created_at'] as Timestamp?)?.toDate(),
        ),
    ], currentYear: _clock().year);
  }

  @override
  Future<void> updateDeal(String id, Map<String, Object?> changes) => _firestore
      .collection(clientsCollection)
      .doc(id)
      .update({...changes, 'deal_updated_at': FieldValue.serverTimestamp()});
}
