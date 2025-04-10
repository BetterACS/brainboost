import 'package:equatable/equatable.dart';
import 'package:brainboost/domain/entities/game_entity.dart';

abstract class GamesState extends Equatable {
  const GamesState();

  @override
  List<Object?> get props => [];
}

class GamesInitial extends GamesState {}

class GamesLoading extends GamesState {}

class AllGamesLoaded extends GamesState {
  final List<GamesTypeEntity> games;

  const AllGamesLoaded(this.games);

  @override
  List<Object> get props => [games];
}

class UserGamesLoaded extends GamesState {
  final List<GamesTypeEntity> games;

  const UserGamesLoaded(this.games);

  @override
  List<Object> get props => [games];
}

class SingleGameLoaded extends GamesState {
  final GamesTypeEntity game;

  const SingleGameLoaded(this.game);

  @override
  List<Object> get props => [game];
}

class GameCreated extends GamesState {
  final String id;

  const GameCreated(this.id);

  @override
  List<Object> get props => [id];
}

class GameUpdated extends GamesState {}

class GameDeleted extends GamesState {}

class PlayerHistoryAdded extends GamesState {}

class SharedGameAdded extends GamesState {}

class GamesError extends GamesState {
  final String message;

  const GamesError(this.message);

  @override
  List<Object> get props => [message];
}

class GameNameUpdated extends GamesState {
  final String newName;

  const GameNameUpdated(this.newName);

  @override
  List<Object> get props => [newName];
}

class GameIconUpdated extends GamesState {
  final String newIcon;

  const GameIconUpdated(this.newIcon);

  @override
  List<Object> get props => [newIcon];
}

class FileUploading extends GamesState {
  final double progress;

  const FileUploading(this.progress);

  @override
  List<Object> get props => [progress];
}

class FileUploaded extends GamesState {
  final String downloadUrl;

  const FileUploaded(this.downloadUrl);

  @override
  List<Object> get props => [downloadUrl];
}