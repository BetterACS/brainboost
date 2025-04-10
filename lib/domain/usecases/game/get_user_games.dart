import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/domain/entities/game_entity.dart';
import 'package:brainboost/domain/repositories/game_repository.dart';

class GetUserGames {
  final GameRepository repository;

  GetUserGames(this.repository);

  Future<Either<Failure, List<GamesTypeEntity>>> call(GetUserGamesParams params) async {
    return await repository.getUserGames(params.email);
  }
}

class GetUserGamesParams extends Equatable {
  final String email;

  const GetUserGamesParams({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}