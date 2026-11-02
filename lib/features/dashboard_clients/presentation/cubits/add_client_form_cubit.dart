import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/client_registration_options.dart';
import '../../domain/entities/client_stage.dart';

/// The choices of the "new client" form; typed fields live in controllers.
class AddClientFormState extends Equatable {
  /// Null until picked (the field is required).
  final String? sector;
  final ClientStage stage;

  /// Inspector name; empty for "بدون إسناد الآن".
  final String inspector;
  final bool schedulePreInspection;

  const AddClientFormState({
    this.sector,
    this.stage = ClientStage.potential,
    this.inspector = '',
    this.schedulePreInspection = true,
  });

  AddClientFormState copyWith({
    String? sector,
    ClientStage? stage,
    String? inspector,
    bool? schedulePreInspection,
  }) => AddClientFormState(
    sector: sector ?? this.sector,
    stage: stage ?? this.stage,
    inspector: inspector ?? this.inspector,
    schedulePreInspection: schedulePreInspection ?? this.schedulePreInspection,
  );

  @override
  List<Object?> get props => [sector, stage, inspector, schedulePreInspection];
}

/// Opens on: no sector, "محتمل", unassigned, pre-inspection on.
class AddClientFormCubit extends Cubit<AddClientFormState> {
  final ClientRegistrationOptions options;

  AddClientFormCubit(this.options) : super(const AddClientFormState());

  void selectSector(String sector) => emit(state.copyWith(sector: sector));

  void selectStage(ClientStage stage) => emit(state.copyWith(stage: stage));

  void selectInspector(String inspector) =>
      emit(state.copyWith(inspector: inspector));

  /// Assigns the inspector with the fewest visits this week.
  void assignSuggestedInspector() {
    final suggested = options.suggestedInspector;
    if (suggested != null) emit(state.copyWith(inspector: suggested.name));
  }

  void setSchedulePreInspection(bool value) =>
      emit(state.copyWith(schedulePreInspection: value));
}
