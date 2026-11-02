import 'package:hassen_dashboard/features/visits/data/datasources/open_actions_datasource.dart';
import 'package:hassen_dashboard/features/visits/domain/entities/facility_open_action.dart';

import '../fixtures/visits_fixture.dart';

/// Serves [actions] — the original screen's open actions unless replaced.
class FakeOpenActionsDataSource implements OpenActionsDataSource {
  List<FacilityOpenAction> actions = [...expectedOpenActions];

  @override
  Future<List<FacilityOpenAction>> getOpenActions() async => [...actions];
}
