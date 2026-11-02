import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/client.dart';
import '../entities/client_registration_options.dart';
import '../entities/new_client.dart';

abstract interface class ClientsRepository {
  Future<Either<Failure, List<Client>>> getClients();

  Future<Either<Failure, ClientRegistrationOptions>> getRegistrationOptions();

  /// Registers [client] (no findings or contract yet) and returns the record.
  Future<Either<Failure, Client>> addClient(NewClient client);
}
