import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:brainboost/domain/entities/game_entity.dart';

abstract class GamesEvent extends Equatable {
  const GamesEvent();

  @override
  List<Object?> get props => [];
}

class GetAllGamesEvent extends GamesEvent {}

class GetGameByIdEvent extends GamesEvent {
  final String id;

  const GetGameByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GetUserGamesEvent extends GamesEvent {
  final String email;

  const GetUserGamesEvent(this.email);

  @override
  List<Object> get props => [email];
}

class CreateGameEvent extends GamesEvent {
  final GamesTypeEntity game;

  const CreateGameEvent(this.game);

  @override
  List<Object> get props => [game];
}

class UpdateGameEvent extends GamesEvent {
  final GamesTypeEntity game;

  const UpdateGameEvent(this.game);

  @override
  List<Object> get props => [game];
}

class DeleteGameEvent extends GamesEvent {
  final String id;
  final String userEmail;

  const DeleteGameEvent(this.id, this.userEmail);

  @override
  List<Object> get props => [id, userEmail];
}

class AddPlayerHistoryEvent extends GamesEvent {
  final String gameId;
  final String playerId;
  final int score;

  const AddPlayerHistoryEvent({
    required this.gameId,
    required this.playerId,
    required this.score,
  });

  @override
  List<Object> get props => [gameId, playerId, score];
}

class AddSharedGameEvent extends GamesEvent {
  final String email;
  final String gamePath;

  const AddSharedGameEvent({
    required this.email,
    required this.gamePath,
  });

  @override
  List<Object> get props => [email, gamePath];
}

class UpdateGameNameEvent extends GamesEvent {
  final String gamePath;
  final String newName;
  final String? userEmail;

  const UpdateGameNameEvent({
    required this.gamePath,
    required this.newName,
    this.userEmail,
  });

  @override
  List<Object?> get props => [gamePath, newName, userEmail];
}

class UpdateGameIconEvent extends GamesEvent {
  final String gamePath;
  final String newIcon;

  const UpdateGameIconEvent({
    required this.gamePath,
    required this.newIcon,
  });

  @override
  List<Object> get props => [gamePath, newIcon];
}

class UploadFileEvent extends GamesEvent {
  final File file;
  final String fileName;

  const UploadFileEvent({
    required this.file,
    required this.fileName,
  });

  @override
  List<Object> get props => [file, fileName];
}

class CreateGameFromPdfEvent extends GamesEvent {
  final String pdfUrl;
  final String gameName;
  final String userEmail;
  final List<dynamic>? gameData;

  const CreateGameFromPdfEvent({
    required this.pdfUrl,
    required this.gameName,
    required this.userEmail,
    this.gameData,
  });

  @override
  List<Object?> get props => [pdfUrl, gameName, userEmail, gameData];
}

class AddLectureToGameEvent extends GamesEvent {
  final String pdfUrl;
  final String gamePath;
  final List<dynamic>? newGameData;

  const AddLectureToGameEvent({
    required this.pdfUrl,
    required this.gamePath,
    this.newGameData,
  });

  @override
  List<Object?> get props => [pdfUrl, gamePath, newGameData];
}