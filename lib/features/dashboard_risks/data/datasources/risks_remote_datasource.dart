import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/risk_model.dart';

/// The risk register, in Firebase. Throws Firestore's own exceptions; the
/// repository maps them.
abstract interface class RisksRemoteDataSource {
  /// Every readable risk in `risks`, in the order they were added.
  Future<List<RiskModel>> getRisks();
}

/// Reads the Firestore `risks` collection (see [RiskModel]).
class FirestoreRisksDataSource implements RisksRemoteDataSource {
  static const risksCollection = 'risks';

  final FirebaseFirestore _firestore;

  FirestoreRisksDataSource(this._firestore);

  @override
  Future<List<RiskModel>> getRisks() async {
    final snapshot = await _firestore.collection(risksCollection).get();
    // Oldest first; sorted here, so the query needs no index.
    int at(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
        (doc.data()['created_at'] as Timestamp?)?.millisecondsSinceEpoch ??
        double.maxFinite.toInt();
    final docs = snapshot.docs.toList()..sort((a, b) => at(a).compareTo(at(b)));
    return [
      for (final doc in docs) ?RiskModel.fromDocument(doc.id, doc.data()),
    ];
  }
}
