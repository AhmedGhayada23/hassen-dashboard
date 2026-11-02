import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// The admin still signed in on this device ("remember me"), or null when
/// the sign-in page is needed. A remembered non-admin is signed out.
class GetSignedInAdmin extends UseCase<AuthUser?, NoParams> {
  final AuthRepository repository;

  GetSignedInAdmin(this.repository);

  @override
  Future<Either<Failure, AuthUser?>> call(NoParams params) async {
    final result = await repository.getCurrentUser();
    return result.fold(Left.new, (user) async {
      if (user == null || user.isAdmin) return Right(user);
      await repository.signOut();
      return const Right(null);
    });
  }
}
