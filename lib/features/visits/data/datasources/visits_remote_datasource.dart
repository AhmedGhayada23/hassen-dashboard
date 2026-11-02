import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/visit_facility.dart';
import '../models/inspector_model.dart';
import '../models/visit_model.dart';

/// The schedule's people, places and bookings, all in Firebase. Throws
/// Firestore's own exceptions; the repository maps them.
abstract interface class VisitsRemoteDataSource {
  /// The safety inspectors in `users`, in the order they were added.
  Future<List<InspectorModel>> getInspectors();

  /// The bookings in `visits` dated [from] to [to] (`yyyy-MM-dd`, both
  /// included), in the order they were made.
  Future<List<VisitModel>> getVisits({
    required String from,
    required String to,
  });

  /// Stores [visit] in `visits` (tasks included) and each of its tasks in
  /// `tasks`, all at once.
  Future<void> addVisit(VisitModel visit);

  /// The clients in `clients`, as places a visit can be booked at.
  Future<List<VisitFacility>> getFacilities();
}

/// Firestore collections:
/// * `users` — inspectors are the documents whose `role` is [inspectorRole].
/// * `visits` — one document per booking, its tasks included (see
///   [VisitModel]).
/// * `tasks` — one document per task of a booking, id `<visit id>_<order>`
///   (see [VisitModel.taskDocuments]).
/// * `clients` — `name`, `stage` ("contracted" means under contract) and
///   `type`, the sector that picks the inspection template.
class FirestoreVisitsDataSource implements VisitsRemoteDataSource {
  static const usersCollection = 'users';
  static const visitsCollection = 'visits';
  static const tasksCollection = 'tasks';
  static const clientsCollection = 'clients';
  static const inspectorRole = 'inspector';
  static const contractedStage = 'contracted';

  final FirebaseFirestore _firestore;

  FirestoreVisitsDataSource(this._firestore);

  @override
  Future<List<InspectorModel>> getInspectors() async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: inspectorRole)
        .get();
    return [
      for (final doc in _byCreation(snapshot.docs))
        if (InspectorModel.fromUserDocument(doc.id, doc.data())
            case final inspector when inspector.name.isNotEmpty)
          inspector,
    ];
  }

  @override
  Future<List<VisitModel>> getVisits({
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
      for (final doc in _byCreation(snapshot.docs))
        VisitModel.fromDocument(doc.data()),
    ];
  }

  @override
  Future<void> addVisit(VisitModel visit) {
    final createdAt = FieldValue.serverTimestamp();
    final visitRef = _firestore.collection(visitsCollection).doc();
    // One batch: the visit and its tasks are stored together or not at all.
    final batch = _firestore.batch()
      ..set(visitRef, {...visit.toJson(), 'created_at': createdAt});
    for (final task in visit.taskDocuments(visitRef.id)) {
      batch.set(
        _firestore
            .collection(tasksCollection)
            .doc('${visitRef.id}_${task['order']}'),
        {...task, 'created_at': createdAt},
      );
    }
    return batch.commit();
  }

  @override
  Future<List<VisitFacility>> getFacilities() async {
    final snapshot = await _firestore.collection(clientsCollection).get();
    return [
      for (final doc in _byCreation(snapshot.docs))
        if ((doc.data()['name'] as String? ?? '').trim() case final name
            when name.isNotEmpty)
          VisitFacility(
            name: name,
            isContracted: doc.data()['stage'] == contractedStage,
            sector: (doc.data()['type'] as String? ?? '').trim(),
          ),
    ];
  }

  /// Oldest first; documents without a timestamp yet (just written) last.
  /// Sorted here, so the queries need no composite index.
  static List<QueryDocumentSnapshot<Map<String, dynamic>>> _byCreation(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    int at(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
        (doc.data()['created_at'] as Timestamp?)?.millisecondsSinceEpoch ??
        double.maxFinite.toInt();
    return docs.toList()..sort((a, b) => at(a).compareTo(at(b)));
  }
}
