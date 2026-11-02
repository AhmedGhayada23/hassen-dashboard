import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report_activity_model.dart';
import '../models/report_facility_model.dart';

/// What monthly reports are built from, all in Firebase. Throws Firestore's
/// own exceptions; the repository maps them.
abstract interface class ReportsRemoteDataSource {
  /// The contracted clients, oldest first.
  Future<List<ReportFacilityModel>> getFacilities();

  /// Everything that happened in [month] (`yyyy-MM`) at any facility.
  Future<List<ReportActivityModel>> getActivities(String month);

  /// Client id → day sent (`yyyy-MM-dd`) for [month]'s reports.
  Future<Map<String, String>> getSentDates(String month);

  /// Stores a delivery record (see `ReportDeliveryModel`) under [id].
  Future<void> recordDelivery(String id, Map<String, Object?> document);
}

/// Reads `clients`, `visits`, `risks`, `corrective_actions` and
/// `report_deliveries`; writes `report_deliveries`.
class FirestoreReportsDataSource implements ReportsRemoteDataSource {
  static const clientsCollection = 'clients';
  static const visitsCollection = 'visits';
  static const risksCollection = 'risks';
  static const actionsCollection = 'corrective_actions';
  static const deliveriesCollection = 'report_deliveries';

  final FirebaseFirestore _firestore;

  FirestoreReportsDataSource(this._firestore);

  @override
  Future<List<ReportFacilityModel>> getFacilities() async {
    final snapshot = await _firestore.collection(clientsCollection).get();
    final docs = snapshot.docs.toList()
      ..sort((a, b) => _createdAt(a).compareTo(_createdAt(b)));
    return [
      for (final doc in docs)
        ?ReportFacilityModel.fromClient(doc.id, doc.data()),
    ];
  }

  @override
  Future<List<ReportActivityModel>> getActivities(String month) async {
    // Future.wait (unlike a record's .wait) rethrows the first error as is,
    // so the repository still sees a FirebaseException.
    final [visits, risks, actions] = await Future.wait([
      // A range on a single field needs no composite index.
      _firestore
          .collection(visitsCollection)
          .where('date', isGreaterThanOrEqualTo: '$month-01')
          .where('date', isLessThanOrEqualTo: '$month-31')
          .get(),
      _firestore.collection(risksCollection).get(),
      _firestore.collection(actionsCollection).get(),
    ]);
    // Risks and actions are read whole, then kept to the month they were
    // raised in.
    final raised = [
      for (final doc in risks.docs)
        ?ReportActivityModel.fromRisk(doc.data(), _date(doc)),
      for (final doc in actions.docs)
        ?ReportActivityModel.fromAction(doc.data(), _date(doc)),
    ];
    return [
      for (final doc in visits.docs) ?ReportActivityModel.fromVisit(doc.data()),
      ...raised.where((a) => a.date.startsWith(month)),
    ];
  }

  @override
  Future<Map<String, String>> getSentDates(String month) async {
    final snapshot = await _firestore
        .collection(deliveriesCollection)
        .where('month', isEqualTo: month)
        .get();
    return {
      for (final doc in snapshot.docs)
        if ((doc.data()['client_id'], doc.data()['sent_on']) case (
          final String client,
          final String on,
        ))
          client: on,
    };
  }

  @override
  Future<void> recordDelivery(String id, Map<String, Object?> document) =>
      _firestore.collection(deliveriesCollection).doc(id).set({
        ...document,
        'sent_at': FieldValue.serverTimestamp(),
      });

  static DateTime? _date(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      (doc.data()['created_at'] as Timestamp?)?.toDate();

  /// Clients still being saved (no timestamp yet) sort last.
  static int _createdAt(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      _date(doc)?.millisecondsSinceEpoch ?? double.maxFinite.toInt();
}
