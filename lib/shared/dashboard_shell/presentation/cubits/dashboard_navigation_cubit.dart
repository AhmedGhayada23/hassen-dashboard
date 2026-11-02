import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/nav_destination.dart';

/// Holds the active sidebar destination. Defaults to [NavDestination.overview], where the app opens after sign-in.
class DashboardNavigationCubit extends Cubit<NavDestination> {
  DashboardNavigationCubit({NavDestination initial = NavDestination.overview})
    : super(initial);

  void select(NavDestination destination) {
    // Cubit only dedupes after its first emit, so guard explicitly.
    if (destination != state) emit(destination);
  }
}
