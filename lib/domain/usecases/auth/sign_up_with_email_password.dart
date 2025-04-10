import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/domain/entities/user_entity.dart';
import 'package:brainboost/domain/repositories/auth_repository.dart';

class SignUpWithEmailPassword {
  final AuthRepository repository;

  SignUpWithEmailPassword(this.repository);

  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;

  const SignUpParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}