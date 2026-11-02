import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failures.dart';
import '../repositories/auth_repository.dart';

/// Signs in, then admits only admins: anyone else is signed straight back
/// out and refused with [AccessDeniedFailure].
class SignIn extends UseCase<AuthUser, SignInParams> {
  final AuthRepository repository;

  SignIn(this.repository);

  @override
  Future<Either<Failure, AuthUser>> call(SignInParams params) async {
    final result = await repository.signIn(
      email: params.email,
      password: params.password,
      rememberMe: params.rememberMe,
    );
    return result.fold(Left.new, (user) async {
      if (user.isAdmin) return Right(user);
      await repository.signOut();
      return const Left(AccessDeniedFailure());
    });
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const SignInParams({
    required this.email,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}
