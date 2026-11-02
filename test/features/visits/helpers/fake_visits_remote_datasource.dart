import 'package:hassen_dashboard/features/visits/data/datasources/visits_remote_datasource.dart';
import 'package:hassen_dashboard/features/visits/data/models/inspector_model.dart';
import 'package:hassen_dashboard/features/visits/data/models/visit_model.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/visit_facility.dart';

import '../fixtures/visits_fixture.dart';

/// In-memory stand-in for Firebase, seeded with the original week's four
/// inspectors, thirteen visits and eight facilities. Keeps the visits it is
/// given; throws [error] when set.
class FakeVisitsRemoteDataSource implements VisitsRemoteDataSource {
  List<InspectorModel> inspectors = [
    for (final i in expectedSchedule.inspectors)
      InspectorModel(id: i.id, name: i.name),
  ];
  List<VisitModel> visits = [
    for (final v in expectedSchedule.visits) VisitModel.fromEntity(v),
  ];
  List<VisitFacility> facilities = [...expectedOptions.facilities];
  final added = <VisitModel>[];
  Object? error;

  @override
  Future<List<InspectorModel>> getInspectors() async {
    if (error case final e?) throw e;
    return [...inspectors];
  }

  @override
  Future<List<VisitModel>> getVisits({
    required String from,
    required String to,
  }) async {
    if (error case final e?) throw e;
    return [
      for (final v in visits)
        if (v.date.compareTo(from) >= 0 && v.date.compareTo(to) <= 0) v,
    ];
  }

  @override
  Future<void> addVisit(VisitModel visit) async {
    if (error case final e?) throw e;
    added.add(visit);
    visits = [...visits, visit];
  }

  @override
  Future<List<VisitFacility>> getFacilities() async {
    if (error case final e?) throw e;
    return [...facilities];
  }
}
