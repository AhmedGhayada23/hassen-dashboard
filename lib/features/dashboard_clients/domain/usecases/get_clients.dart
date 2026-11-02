import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/client.dart';
import '../repositories/clients_repository.dart';

class GetClients extends UseCase<List<Client>, NoParams> {
  final ClientsRepository repository;

  GetClients(this.repository);

  @override
  Future<Either<Failure, List<Client>>> call(NoParams params) =>
      repository.getClients();
}
