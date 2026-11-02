import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/client_registration_options.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/entities/new_client.dart';
import 'package:hassen_dashboard/features/dashboard_clients/domain/repositories/clients_repository.dart';

import '../fixtures/clients_fixture.dart';

/// Repository stub over the original eight clients. [addClient] records
/// [added] and appends a record built like the real one, or answers
/// [addFailure] when set.
class FakeClientsRepository implements ClientsRepository {
  List<Client> clients = [...expectedClients];
  ClientRegistrationOptions options = expectedRegistrationOptions;
  Failure? failure;
  Failure? optionsFailure;
  Failure? addFailure;
  Completer<void>? gate;
  final added = <NewClient>[];

  @override
  Future<Either<Failure, List<Client>>> getClients() async {
    await gate?.future;
    return failure != null ? Left(failure!) : Right(clients);
  }

  @override
  Future<Either<Failure, ClientRegistrationOptions>>
  getRegistrationOptions() async =>
      optionsFailure != null ? Left(optionsFailure!) : Right(options);

  @override
  Future<Either<Failure, Client>> addClient(NewClient client) async {
    added.add(client);
    if (addFailure case final failure?) return Left(failure);
    final record = Client(
      id: 'CL-${(clients.length + 1).toString().padLeft(3, '0')}',
      name: client.name.trim(),
      type: client.sector,
      branches: client.branches,
      stage: client.stage,
      openFindings: 0,
      compliance: null,
      contract: NewClient.unknown,
      visits: client.visitsLine,
      inspector: client.inspectorLine,
      contact: client.contactLine,
      city: client.cityLine,
    );
    clients = [...clients, record];
    return Right(record);
  }
}
