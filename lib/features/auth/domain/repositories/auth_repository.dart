import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  /// Signs in and returns the account with its stored profile.
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// The account still signed in on this device (with its profile), if any.
  Future<Either<Failure, AuthUser?>> getCurrentUser();

  Future<Either<Failure, Unit>> signOut();
}
