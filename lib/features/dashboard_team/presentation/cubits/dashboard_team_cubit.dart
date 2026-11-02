import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/new_employee.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/usecases/add_employee.dart';
import '../../domain/usecases/get_employee_roles.dart';
import '../../domain/usecases/get_team_members.dart';
import 'dashboard_team_state.dart';

/// Loads the team roster with the roles a new employee can get, creates
/// employee accounts, and shows or hides their temporary passwords.
class DashboardTeamCubit extends Cubit<DashboardTeamState> {
  final GetTeamMembers _getMembers;
  final GetEmployeeRoles _getRoles;
  final AddEmployee _addEmployee;

  DashboardTeamCubit(this._getMembers, this._getRoles, this._addEmployee)
    : super(const DashboardTeamInitial());

  Future<void> load() async {
    emit(const DashboardTeamLoading());
    final members = await _getMembers(const NoParams());
    final roles = await _getRoles(const NoParams());
    if (isClosed) return;
    emit(
      members.fold(
        DashboardTeamFailure.new,
        (m) => roles.fold(
          DashboardTeamFailure.new,
          (r) => DashboardTeamLoaded(m, r),
        ),
      ),
    );
  }

  /// Ignored until the roster has loaded, and while another account is
  /// being created.
  Future<void> addEmployee(NewEmployee employee) async {
    final current = state;
    if (current is! DashboardTeamLoaded || current.isAdding) return;
    emit(current.copyWith(isAdding: true));
    final result = await _addEmployee(employee);
    if (isClosed) return;
    final latest = state as DashboardTeamLoaded;
    emit(
      result.fold(
        (failure) => latest.copyWith(isAdding: false, actionFailure: failure),
        (member) => latest.copyWith(
          members: [...latest.members, member],
          isAdding: false,
          lastAdded: member,
        ),
      ),
    );
  }

  /// Shows [member]'s temporary password in clear, or masks it again.
  void togglePasswordVisibility(TeamMember member) {
    final current = state;
    if (current is! DashboardTeamLoaded) return;
    final revealed = {...current.revealedPasswordIds};
    if (!revealed.remove(member.id)) revealed.add(member.id);
    emit(current.copyWith(revealedPasswordIds: revealed));
  }
}
