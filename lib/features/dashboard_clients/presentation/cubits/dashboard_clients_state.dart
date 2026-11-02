import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_stage.dart';
import '../../domain/entities/clients_summary.dart';

sealed class DashboardClientsState extends Equatable {
  const DashboardClientsState();

  @override
  List<Object?> get props => [];
}

final class DashboardClientsInitial extends DashboardClientsState {
  const DashboardClientsInitial();
}

final class DashboardClientsLoading extends DashboardClientsState {
  const DashboardClientsLoading();
}

final class DashboardClientsFailure extends DashboardClientsState {
  final Failure failure;

  const DashboardClientsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// The client just registered, and whether its pre-contract inspection
/// should be scheduled.
typedef ClientAddition = ({Client client, bool schedulePreInspection});

final class DashboardClientsLoaded extends DashboardClientsState {
  final List<Client> clients;

  /// Active stage filter; null means "الكل".
  final ClientStage? stageFilter;

  /// Selection by stable id — always one of [visibleClients], or null when none.
  final String? selectedClientId;

  /// The "new client" form's options (inspectors from Firebase) are loading.
  final bool isPreparingForm;

  /// A new client is being saved.
  final bool isAdding;

  /// Set right after a registration, for a one-off confirmation.
  final ClientAddition? lastAdded;

  /// Set when the last registration failed; cleared by the next change.
  final Failure? actionFailure;

  /// Set when the form's options could not be loaded; cleared by the next
  /// change.
  final Failure? formFailure;

  const DashboardClientsLoaded({
    required this.clients,
    this.stageFilter,
    this.selectedClientId,
    this.isPreparingForm = false,
    this.isAdding = false,
    this.lastAdded,
    this.actionFailure,
    this.formFailure,
  });

  static List<Client> filter(List<Client> clients, ClientStage? stage) =>
      stage == null ? clients : clients.where((c) => c.stage == stage).toList();

  List<Client> get visibleClients => filter(clients, stageFilter);

  Client? get selectedClient =>
      visibleClients.where((c) => c.id == selectedClientId).firstOrNull;

  ClientsSummary get summary => ClientsSummary.fromClients(clients);

  /// Same clients and view; the one-off outcome fields are dropped unless
  /// given.
  DashboardClientsLoaded copyWith({
    List<Client>? clients,
    ClientStage? Function()? stageFilter,
    String? Function()? selectedClientId,
    bool? isPreparingForm,
    bool? isAdding,
    ClientAddition? lastAdded,
    Failure? actionFailure,
    Failure? formFailure,
  }) => DashboardClientsLoaded(
    clients: clients ?? this.clients,
    stageFilter: stageFilter != null ? stageFilter() : this.stageFilter,
    selectedClientId: selectedClientId != null
        ? selectedClientId()
        : this.selectedClientId,
    isPreparingForm: isPreparingForm ?? this.isPreparingForm,
    isAdding: isAdding ?? this.isAdding,
    lastAdded: lastAdded,
    actionFailure: actionFailure,
    formFailure: formFailure,
  );

  @override
  List<Object?> get props => [
    clients,
    stageFilter,
    selectedClientId,
    isPreparingForm,
    isAdding,
    lastAdded,
    actionFailure,
    formFailure,
  ];
}
