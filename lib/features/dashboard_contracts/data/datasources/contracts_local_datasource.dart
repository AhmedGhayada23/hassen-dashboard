import '../../../../core/errors/exceptions.dart';
import '../models/contract_plan_model.dart';

/// The contract lengths on offer. The deals themselves live on the clients in
/// Firebase (`ContractsRemoteDataSource`).
class ContractsLocalDataSource {
  final List<Map<String, Object?>> _plansJson;

  const ContractsLocalDataSource({
    List<Map<String, Object?>> plansJson = contractPlansJson,
  }) : _plansJson = plansJson;

  /// Throws [ParseException] when the payload doesn't match the expected shape.
  Future<List<ContractPlanModel>> getContractPlans() async {
    try {
      return [for (final item in _plansJson) ContractPlanModel.fromJson(item)];
    } catch (_) {
      throw ParseException();
    }
  }

  // مدد التعاقد المتاحة.
  static const contractPlansJson = <Map<String, Object?>>[
    {'id': 'm', 'name': 'شهر', 'months': 1},
    {'id': 'q', 'name': '3 شهور', 'months': 3},
    {'id': 'h', 'name': '6 شهور', 'months': 6},
    {'id': 'y', 'name': 'سنوي — يتجدد تلقائياً', 'months': 12},
  ];
}
