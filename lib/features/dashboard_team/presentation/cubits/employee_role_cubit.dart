import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/employee_role.dart';

/// The role picked in the "add employee" dialog; starts on the first role.
class EmployeeRoleCubit extends Cubit<EmployeeRole> {
  EmployeeRoleCubit(List<EmployeeRole> roles) : super(roles.first);

  void select(EmployeeRole role) => emit(role);
}
