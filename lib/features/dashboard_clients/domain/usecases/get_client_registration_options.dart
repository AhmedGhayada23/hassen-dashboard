import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/client_registration_options.dart';
import '../repositories/clients_repository.dart';

class GetClientRegistrationOptions
    extends UseCase<ClientRegistrationOptions, NoParams> {
  final ClientsRepository repository;

  GetClientRegistrationOptions(this.repository);

  @override
  Future<Either<Failure, ClientRegistrationOptions>> call(NoParams params) =>
      repository.getRegistrationOptions();
}
