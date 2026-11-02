import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/client.dart';
import '../entities/client_stage.dart';
import '../entities/new_client.dart';
import '../failures/client_failures.dart';
import '../repositories/clients_repository.dart';

/// Registers a [NewClient]. Refuses a duplicate name (as the form does), a
/// missing name, sector or contact, fewer than one branch, and a stage a new
/// client cannot start in.
class AddClient extends UseCase<Client, NewClient> {
  final ClientsRepository repository;

  AddClient(this.repository);

  @override
  Future<Either<Failure, Client>> call(NewClient client) async {
    final name = client.name.trim();
    if (name.isEmpty ||
        client.sector.isEmpty ||
        client.contactName.trim().isEmpty ||
        client.branches < 1 ||
        !ClientStage.forNewClient.contains(client.stage)) {
      return const Left(ValidationFailure(message: 'Incomplete new client.'));
    }
    final existing = await repository.getClients();
    return existing.fold(Left.new, (clients) {
      if (clients.any((c) => c.name == name)) {
        return const Left(DuplicateClientFailure());
      }
      return repository.addClient(client);
    });
  }
}
