import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/auth/domain/entities/auth_user.dart';
import 'package:hassen_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:hassen_dashboard/features/auth/domain/usecases/sign_in.dart';

/// Records every sign-in request; answers with a failure unless told
/// otherwise. [gate] holds the answer back to observe the loading state.
class FakeAuthRepository implements AuthRepository {
  final calls = <SignInParams>[];
  Either<Failure, AuthUser> result = const Left(UnknownFailure());
  Either<Failure, AuthUser?> current = const Right(null);
  Completer<void>? gate;
  int signOuts = 0;

  @override
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    calls.add(
      SignInParams(email: email, password: password, rememberMe: rememberMe),
    );
    await gate?.future;
    return result;
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async => current;

  @override
  Future<Either<Failure, Unit>> signOut() async {
    signOuts++;
    return const Right(unit);
  }
}

/// The dashboard admin as stored in `users`.
const adminUser = AuthUser(
  id: 'uid-admin',
  email: 'ahmedghayada123@gmail.com',
  displayName: 'مدير العمليات',
  role: 'admin',
);

const inspectorUser = AuthUser(
  id: 'uid-inspector',
  email: 'inspector@haseen.ps',
  displayName: 'م. أحمد',
  role: 'inspector',
);
