import 'package:equatable/equatable.dart';

abstract class GameContentEntity extends Equatable {
  const GameContentEntity();
}

class GameQuizContentEntity extends GameContentEntity {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  const GameQuizContentEntity({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  @override
  List<Object> get props => [question, options, correctAnswerIndex];
}

class GameYesNoContentEntity extends GameContentEntity {
  final String question;
  final bool correctAnswer;

  const GameYesNoContentEntity({
    required this.question,
    required this.correctAnswer,
  });

  @override
  List<Object> get props => [question, correctAnswer];
}

class GameBingoContentItemEntity extends Equatable {
  final String question;
  final String answer;
  final int point;

  const GameBingoContentItemEntity({
    required this.question,
    required this.answer,
    required this.point,
  });

  @override
  List<Object> get props => [question, answer, point];
}

class BingoContentEntity extends GameContentEntity {
  final List<GameBingoContentItemEntity> bingoList;

  const BingoContentEntity({required this.bingoList});

  @override
  List<Object> get props => [bingoList];
}

class GameEntity extends Equatable {
  final String id;
  final String gameType;
  final GameContentEntity content;

  const GameEntity({
    required this.id,
    required this.gameType,
    required this.content,
  });

  @override
  List<Object> get props => [id, gameType, content];
}

class GamesTypeEntity extends Equatable {
  final String id;
  final String author;
  final String name;
  final String description;
  final String icon;
  final List<GameEntity> gameList;
  final String media;
  final List<PlayerHistoryEntity> playedHistory;

  const GamesTypeEntity({
    required this.id,
    required this.author,
    required this.name,
    required this.description,
    required this.icon,
    required this.gameList,
    required this.media,
    required this.playedHistory,
  });

  @override
  List<Object> get props => [
        id,
        author,
        name,
        description,
        icon,
        gameList,
        media,
        playedHistory,
      ];
}

class PlayerHistoryEntity extends Equatable {
  final String playerId;
  final int score;

  const PlayerHistoryEntity({
    required this.playerId,
    required this.score,
  });

  @override
  List<Object> get props => [playerId, score];
}