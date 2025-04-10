import 'package:dartz/dartz.dart';
import 'package:brainboost/core/errors/exceptions.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'package:brainboost/data/datasources/remote/firebase_user_datasource.dart';
import 'package:brainboost/domain/entities/user_entity.dart';
import 'package:brainboost/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseUserDataSource dataSource;

  UserRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, UserEntity>> getUserProfile({
    required String email,
  }) async {
    try {
      final user = await dataSource.getUserProfile(email: email);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    required String email,
    String? username,
    String? profileImageUrl,
    int? age,
  }) async {
    try {
      await dataSource.updateUserProfile(
        email: email,
        username: username,
        profileImageUrl: profileImageUrl,
        age: age,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addUser({
    required String email,
  }) async {
    try {
      await dataSource.addUser(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUserGames({
    required String email,
  }) async {
    try {
      final games = await dataSource.getUserGames(email: email);
      return Right(games);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addSharedGame({
    required String email,
    required String gamePath,
  }) async {
    try {
      await dataSource.addSharedGame(email: email, gamePath: gamePath);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}