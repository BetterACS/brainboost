import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/domain/entities/user_entity.dart';
import 'package:brainboost/domain/repositories/auth_repository.dart';

class SignInWithEmailPassword {
  final AuthRepository repository;

  SignInWithEmailPassword(this.repository);

  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}