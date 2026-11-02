import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/client_registration_options.dart';
import '../../domain/entities/client_stage.dart';
import '../../domain/entities/new_client.dart';
import '../../domain/usecases/add_client.dart';
import '../../domain/usecases/get_client_registration_options.dart';
import '../../domain/usecases/get_clients.dart';
import 'dashboard_clients_state.dart';

/// Loads clients, manages the stage filter and the selected client, loads the
/// "new client" form's options on demand, and registers new clients.
class DashboardClientsCubit extends Cubit<DashboardClientsState> {
  final GetClients _getClients;
  final GetClientRegistrationOptions _getOptions;
  final AddClient _addClient;

  DashboardClientsCubit(this._getClients, this._getOptions, this._addClient)
    : super(const DashboardClientsInitial());

  Future<void> load() async {
    emit(const DashboardClientsLoading());
    final clients = await _getClients(const NoParams());
    if (isClosed) return;
    emit(
      clients.fold(
        DashboardClientsFailure.new,
        (list) => DashboardClientsLoaded(
          clients: list,
          selectedClientId: list.firstOrNull?.id,
        ),
      ),
    );
  }

  /// Loads the "new client" form's options fresh, so inspectors added since
  /// the page opened are offered. Returns null (and reports the failure)
  /// when they cannot be read, and while another load is running.
  Future<ClientRegistrationOptions?> prepareNewClient() async {
    final current = state;
    if (current is! DashboardClientsLoaded || current.isPreparingForm) {
      return null;
    }
    emit(current.copyWith(isPreparingForm: true));
    final result = await _getOptions(const NoParams());
    if (isClosed) return null;
    final latest = state as DashboardClientsLoaded;
    return result.fold(
      (failure) {
        emit(latest.copyWith(isPreparingForm: false, formFailure: failure));
        return null;
      },
      (options) {
        emit(latest.copyWith(isPreparingForm: false));
        return options;
      },
    );
  }

  /// Applies [stage] (null = all). Keeps the selection if it is still visible,
  /// otherwise falls back to the first result, or to none when there is none.
  void selectStage(ClientStage? stage) {
    final current = state;
    if (current is! DashboardClientsLoaded || stage == current.stageFilter) {
      return;
    }
    final visible = DashboardClientsLoaded.filter(current.clients, stage);
    final keepSelection = visible.any((c) => c.id == current.selectedClientId);
    emit(
      current.copyWith(
        stageFilter: () => stage,
        selectedClientId: () =>
            keepSelection ? current.selectedClientId : visible.firstOrNull?.id,
      ),
    );
  }

  /// Selects a client shown in the current results; anything else is ignored.
  void selectClient(String id) {
    final current = state;
    if (current is! DashboardClientsLoaded || id == current.selectedClientId) {
      return;
    }
    if (!current.visibleClients.any((c) => c.id == id)) return;
    emit(current.copyWith(selectedClientId: () => id));
  }

  /// Registers [client]; on success it is selected under the "الكل" filter.
  /// Ignored until the clients have loaded, and while another is saving.
  Future<void> addClient(NewClient client) async {
    final current = state;
    if (current is! DashboardClientsLoaded || current.isAdding) return;
    emit(current.copyWith(isAdding: true));
    final result = await _addClient(client);
    if (isClosed) return;
    final latest = state as DashboardClientsLoaded;
    emit(
      result.fold(
        (failure) => latest.copyWith(isAdding: false, actionFailure: failure),
        (added) => latest.copyWith(
          isAdding: false,
          clients: [...latest.clients, added],
          stageFilter: () => null,
          selectedClientId: () => added.id,
          lastAdded: (
            client: added,
            schedulePreInspection: client.schedulePreInspection,
          ),
        ),
      ),
    );
  }
}
