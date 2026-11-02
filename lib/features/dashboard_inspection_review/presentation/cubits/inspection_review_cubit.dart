import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/inspection.dart';
import '../../domain/usecases/approve_inspection.dart';
import '../../domain/usecases/get_inspections.dart';
import '../../domain/usecases/reset_inspection_decision.dart';
import '../../domain/usecases/return_inspection.dart';
import 'inspection_review_state.dart';

/// Loads the review queue, tracks the selected report, and records decisions.
class InspectionReviewCubit extends Cubit<InspectionReviewState> {
  final GetInspections _getInspections;
  final ApproveInspection _approve;
  final ReturnInspection _return;
  final ResetInspectionDecision _reset;

  InspectionReviewCubit({
    required GetInspections getInspections,
    required ApproveInspection approveInspection,
    required ReturnInspection returnInspection,
    required ResetInspectionDecision resetDecision,
  }) : _getInspections = getInspections,
       _approve = approveInspection,
       _return = returnInspection,
       _reset = resetDecision,
       super(const InspectionReviewInitial());

  Future<void> load() async {
    emit(const InspectionReviewLoading());
    final result = await _getInspections(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        InspectionReviewFailure.new,
        (list) => InspectionReviewLoaded(inspections: list),
      ),
    );
  }

  void select(int index) {
    final current = state;
    if (current is! InspectionReviewLoaded) return;
    if (index < 0 ||
        index >= current.inspections.length ||
        index == current.selectedIndex) {
      return;
    }
    emit(current.copyWith(selectedIndex: index));
  }

  Future<void> approve(String id) => _decide(() => _approve(id));

  Future<void> returnToInspector(String id) => _decide(() => _return(id));

  Future<void> undoDecision(String id) => _decide(() => _reset(id));

  Future<void> _decide(
    Future<Either<Failure, Inspection>> Function() run,
  ) async {
    if (state is! InspectionReviewLoaded) return;
    final result = await run();
    // Re-read: the selection may have changed while saving.
    final current = state;
    if (isClosed || current is! InspectionReviewLoaded) return;
    emit(
      result.fold(
        (failure) => current.copyWith(actionFailure: failure),
        (updated) => current.copyWith(
          inspections: [
            for (final i in current.inspections)
              i.id == updated.id ? updated : i,
          ],
        ),
      ),
    );
  }
}
