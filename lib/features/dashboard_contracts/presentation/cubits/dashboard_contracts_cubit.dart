import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/contract_plan.dart';
import '../../domain/entities/deal.dart';
import '../../domain/usecases/decide_deal.dart';
import '../../domain/usecases/get_contract_plans.dart';
import '../../domain/usecases/get_deals.dart';
import '../../domain/usecases/set_contract_plan.dart';
import 'dashboard_contracts_state.dart';

/// Loads every client's deal with the contract lengths, records accept /
/// reject decisions (and changes to them), and the length of accepted deals.
class DashboardContractsCubit extends Cubit<DashboardContractsState> {
  final GetDeals _getDeals;
  final GetContractPlans _getPlans;
  final AcceptDeal _acceptDeal;
  final RejectDeal _rejectDeal;
  final SetContractPlan _setPlan;

  DashboardContractsCubit({
    required GetDeals getDeals,
    required GetContractPlans getPlans,
    required AcceptDeal acceptDeal,
    required RejectDeal rejectDeal,
    required SetContractPlan setPlan,
  }) : _getDeals = getDeals,
       _getPlans = getPlans,
       _acceptDeal = acceptDeal,
       _rejectDeal = rejectDeal,
       _setPlan = setPlan,
       super(const DashboardContractsInitial());

  Future<void> load() async {
    emit(const DashboardContractsLoading());
    final (deals, plans) = await (
      _getDeals(const NoParams()),
      _getPlans(const NoParams()),
    ).wait;
    if (isClosed) return;
    emit(
      deals.fold(
        DashboardContractsFailure.new,
        (d) => plans.fold(
          DashboardContractsFailure.new,
          (p) => DashboardContractsLoaded(deals: d, plans: p),
        ),
      ),
    );
  }

  /// The contract starts today; a length is picked next.
  Future<void> accept(Deal deal) =>
      _apply(deal, () => _acceptDeal(deal), confirm: true);

  /// Also cancels an accepted deal's contract.
  Future<void> reject(Deal deal) =>
      _apply(deal, () => _rejectDeal(deal), confirm: true);

  Future<void> selectPlan(Deal deal, ContractPlan plan) => _apply(
    deal,
    () => _setPlan(SetContractPlanParams(deal, plan)),
    confirm: false,
  );

  /// Marks [deal] as saving, then swaps the updated deal into the list, or
  /// keeps the list and reports the failure. Ignored until the deals have
  /// loaded, and while [deal] is already being saved.
  Future<void> _apply(
    Deal deal,
    Future<Either<Failure, Deal>> Function() change, {
    required bool confirm,
  }) async {
    final before = state;
    if (before is! DashboardContractsLoaded || before.isSaving(deal)) return;
    emit(
      DashboardContractsLoaded(
        deals: before.deals,
        plans: before.plans,
        savingIds: {...before.savingIds, deal.id},
      ),
    );
    final result = await change();
    final current = state;
    if (isClosed || current is! DashboardContractsLoaded) return;
    final saving = {...current.savingIds}..remove(deal.id);
    emit(
      result.fold(
        (failure) => DashboardContractsLoaded(
          deals: current.deals,
          plans: current.plans,
          savingIds: saving,
          actionFailure: failure,
        ),
        (updated) => DashboardContractsLoaded(
          deals: [
            for (final d in current.deals) d.id == updated.id ? updated : d,
          ],
          plans: current.plans,
          savingIds: saving,
          lastDecided: confirm ? updated : null,
        ),
      ),
    );
  }
}
