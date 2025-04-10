import 'package:dartz/dartz.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/domain/entities/game_entity.dart';
import 'package:brainboost/domain/repositories/game_repository.dart';

class GetAllGames {
  final GameRepository repository;

  GetAllGames(this.repository);

  Future<Either<Failure, List<GamesTypeEntity>>> call() async {
    return await repository.getAllGames();
  }
}