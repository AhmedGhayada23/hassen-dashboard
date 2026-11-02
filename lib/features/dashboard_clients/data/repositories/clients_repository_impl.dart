import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_registration_options.dart';
import '../../domain/entities/new_client.dart';
import '../../domain/repositories/clients_repository.dart';
import '../datasources/clients_remote_datasource.dart';
import '../models/client_model.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final ClientsRemoteDataSource remoteDataSource;

  const ClientsRepositoryImpl(this.remoteDataSource);

  /// The clients in Firebase `clients`.
  @override
  Future<Either<Failure, List<Client>>> getClients() => _guard(
    () async => [
      for (final m in await remoteDataSource.getClients()) m.toEntity(),
    ],
  );

  /// The sectors in `sectors` and the safety inspectors in `users`.
  @override
  Future<Either<Failure, ClientRegistrationOptions>> getRegistrationOptions() =>
      _guard(
        () async => ClientRegistrationOptions(
          sectors: await remoteDataSource.getSectors(),
          inspectors: await remoteDataSource.getInspectors(),
        ),
      );

  /// A new client has no findings, compliance or contract yet.
  @override
  Future<Either<Failure, Client>> addClient(NewClient client) => _guard(
    () async => (await remoteDataSource.addClient(
      ClientModel.newDocument(client),
    )).toEntity(),
  );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on FirebaseException catch (e) {
      return Left(switch (e.code) {
        'permission-denied' => const ForbiddenFailure(),
        'unavailable' => const NetworkFailure(),
        _ => UnknownFailure(message: e.message ?? e.code),
      });
    } on AppException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
