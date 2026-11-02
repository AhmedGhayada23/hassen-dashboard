import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_inspection_templates.dart';
import '../../domain/usecases/get_operation_rules.dart';
import '../../domain/usecases/get_system_roles.dart';
import 'dashboard_settings_state.dart';

/// Loads the inspection templates, roles and operating rules together.
class DashboardSettingsCubit extends Cubit<DashboardSettingsState> {
  final GetInspectionTemplates _getTemplates;
  final GetSystemRoles _getRoles;
  final GetOperationRules _getRules;

  DashboardSettingsCubit({
    required GetInspectionTemplates getTemplates,
    required GetSystemRoles getRoles,
    required GetOperationRules getRules,
  }) : _getTemplates = getTemplates,
       _getRoles = getRoles,
       _getRules = getRules,
       super(const DashboardSettingsInitial());

  Future<void> load() async {
    emit(const DashboardSettingsLoading());
    final (templates, roles, rules) = await (
      _getTemplates(const NoParams()),
      _getRoles(const NoParams()),
      _getRules(const NoParams()),
    ).wait;
    if (isClosed) return;
    // Any card failing fails the page: the three belong to one screen.
    emit(
      templates.fold(
        DashboardSettingsFailure.new,
        (t) => roles.fold(
          DashboardSettingsFailure.new,
          (r) => rules.fold(
            DashboardSettingsFailure.new,
            (u) => DashboardSettingsLoaded(templates: t, roles: r, rules: u),
          ),
        ),
      ),
    );
  }
}
