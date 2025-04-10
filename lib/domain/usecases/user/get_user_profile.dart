import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/domain/entities/user_entity.dart';
import 'package:brainboost/domain/repositories/user_repository.dart';

class GetUserProfile {
  final UserRepository repository;

  GetUserProfile(this.repository);

  Future<Either<Failure, UserEntity>> call(GetUserProfileParams params) async {
    return await repository.getUserProfile(
      email: params.email,
    );
  }
}

class GetUserProfileParams extends Equatable {
  final String email;

  const GetUserProfileParams({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}