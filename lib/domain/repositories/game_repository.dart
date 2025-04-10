import 'package:dartz/dartz.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/domain/entities/game_entity.dart';

abstract class GameRepository {
  /// Get all games
  Future<Either<Failure, List<GamesTypeEntity>>> getAllGames();
  
  /// Get game by ID
  Future<Either<Failure, GamesTypeEntity>> getGameById(String id);
  
  /// Create new game
  Future<Either<Failure, String>> createGame(GamesTypeEntity game);
  
  /// Update game
  Future<Either<Failure, void>> updateGame(GamesTypeEntity game);
  
  /// Delete game
  Future<Either<Failure, void>> deleteGame(String id);
  
  /// Get user games
  Future<Either<Failure, List<GamesTypeEntity>>> getUserGames(String email);
  
  /// Add player history
  Future<Either<Failure, void>> addPlayerHistory({
    required String gameId,
    required String playerId,
    required int score,
  });
}