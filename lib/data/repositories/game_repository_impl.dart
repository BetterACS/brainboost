import 'package:dartz/dartz.dart';
import 'package:brainboost/core/errors/exceptions.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/data/datasources/remote/firebase_game_datasource.dart';
import 'package:brainboost/domain/entities/game_entity.dart';
import 'package:brainboost/domain/repositories/game_repository.dart';
import 'package:brainboost/data/models/game_model.dart';

class GameRepositoryImpl implements GameRepository {
  final FirebaseGameDataSource dataSource;

  GameRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<GamesTypeEntity>>> getAllGames() async {
    try {
      final games = await dataSource.getAllGames();
      return Right(games);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GamesTypeEntity>> getGameById(String id) async {
    try {
      final game = await dataSource.getGameById(id);
      return Right(game);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createGame(GamesTypeEntity game) async {
    try {
      final gameModel = GamesTypeModel.fromEntity(game);
      final id = await dataSource.createGame(gameModel);
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGame(GamesTypeEntity game) async {
    try {
      final gameModel = GamesTypeModel.fromEntity(game);
      await dataSource.updateGame(gameModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGame(String id) async {
    try {
      await dataSource.deleteGame(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GamesTypeEntity>>> getUserGames(String email) async {
    try {
      final games = await dataSource.getUserGames(email);
      return Right(games);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPlayerHistory({
    required String gameId,
    required String playerId,
    required int score,
  }) async {
    try {
      await dataSource.addPlayerHistory(
        gameId: gameId,
        playerId: playerId,
        score: score,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}