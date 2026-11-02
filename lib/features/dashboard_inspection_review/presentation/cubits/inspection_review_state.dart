import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/inspection.dart';

sealed class InspectionReviewState extends Equatable {
  const InspectionReviewState();

  @override
  List<Object?> get props => [];
}

final class InspectionReviewInitial extends InspectionReviewState {
  const InspectionReviewInitial();
}

final class InspectionReviewLoading extends InspectionReviewState {
  const InspectionReviewLoading();
}

final class InspectionReviewFailure extends InspectionReviewState {
  final Failure failure;

  const InspectionReviewFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class InspectionReviewLoaded extends InspectionReviewState {
  final List<Inspection> inspections;
  final int selectedIndex;

  /// Set when the last decision could not be saved; cleared by the next change.
  final Failure? actionFailure;

  const InspectionReviewLoaded({
    required this.inspections,
    this.selectedIndex = 0,
    this.actionFailure,
  });

  Inspection? get selected =>
      inspections.isEmpty ? null : inspections[selectedIndex];

  int get pendingCount => inspections.where((i) => i.isPending).length;

  InspectionReviewLoaded copyWith({
    List<Inspection>? inspections,
    int? selectedIndex,
    Failure? actionFailure,
  }) => InspectionReviewLoaded(
    inspections: inspections ?? this.inspections,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [inspections, selectedIndex, actionFailure];
}
