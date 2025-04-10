import 'package:dartz/dartz.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/domain/entities/user_entity.dart';

abstract class UserRepository {
  /// Get user profile
  Future<Either<Failure, UserEntity>> getUserProfile({
    required String email,
  });

  /// Update user profile
  Future<Either<Failure, void>> updateUserProfile({
    required String email,
    String? username,
    String? profileImageUrl,
    int? age,
  });

  /// Add a new user
  Future<Either<Failure, void>> addUser({
    required String email,
  });

  /// Get user games
  Future<Either<Failure, List<String>>> getUserGames({
    required String email,
  });

  /// Add shared game to user
  Future<Either<Failure, void>> addSharedGame({
    required String email,
    required String gamePath,
  });
}