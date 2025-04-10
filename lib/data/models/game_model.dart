import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/domain/entities/game_entity.dart';

class GameQuizContentModel extends GameQuizContentEntity {
  const GameQuizContentModel({
    required super.question,
    required super.options,
    required super.correctAnswerIndex,
  });

  factory GameQuizContentModel.fromEntity(GameQuizContentEntity entity) {
    return GameQuizContentModel(
      question: entity.question,
      options: entity.options,
      correctAnswerIndex: entity.correctAnswerIndex,
    );
  }

  factory GameQuizContentModel.fromMap(Map<String, dynamic> map) {
    return GameQuizContentModel(
      question: map['question'] as String,
      options: (map['choices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswerIndex: map['correct_idx'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'choices': options,
      'correct_idx': correctAnswerIndex,
    };
  }
}

class GameYesNoContentModel extends GameYesNoContentEntity {
  const GameYesNoContentModel({
    required super.question,
    required super.correctAnswer,
  });

  factory GameYesNoContentModel.fromEntity(GameYesNoContentEntity entity) {
    return GameYesNoContentModel(
      question: entity.question,
      correctAnswer: entity.correctAnswer,
    );
  }

  factory GameYesNoContentModel.fromMap(Map<String, dynamic> map) {
    return GameYesNoContentModel(
      question: map['question'] as String,
      correctAnswer: map['correct_ans'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'correct_ans': correctAnswer,
    };
  }
}

class GameBingoContentItemModel extends GameBingoContentItemEntity {
  const GameBingoContentItemModel({
    required super.question,
    required super.answer,
    required super.point,
  });

  factory GameBingoContentItemModel.fromEntity(GameBingoContentItemEntity entity) {
    return GameBingoContentItemModel(
      question: entity.question,
      answer: entity.answer,
      point: entity.point,
    );
  }

  factory GameBingoContentItemModel.fromMap(Map<String, dynamic> map) {
    return GameBingoContentItemModel(
      question: map['question'] as String,
      answer: map['answer'] as String,
      point: map['point'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'point': point,
    };
  }
}

class BingoContentModel extends BingoContentEntity {
  const BingoContentModel({
    required super.bingoList,
  });

  factory BingoContentModel.fromEntity(BingoContentEntity entity) {
    return BingoContentModel(
      bingoList: entity.bingoList.map((item) => 
        GameBingoContentItemModel.fromEntity(item)).toList(),
    );
  }

  factory BingoContentModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('bingo_list')) {
      return BingoContentModel(
        bingoList: (map['bingo_list'] as List<dynamic>)
            .map((e) => GameBingoContentItemModel.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (map.containsKey('questions') && map.containsKey('answers')) {
      final questions = (map['questions'] as List<dynamic>).map((e) => e as String).toList();
      final answers = (map['answers'] as List<dynamic>).map((e) => e as String).toList();
      final points = map.containsKey('points') 
          ? (map['points'] as List<dynamic>).map((e) => e as int).toList()
          : List.generate(questions.length, (_) => 10);

      final bingoList = <GameBingoContentItemModel>[];
      for (int i = 0; i < questions.length; i++) {
        bingoList.add(GameBingoContentItemModel(
          question: questions[i],
          answer: answers[i],
          point: i < points.length ? points[i] : 10,
        ));
      }
      return BingoContentModel(bingoList: bingoList);
    }
    return const BingoContentModel(bingoList: []);
  }

  Map<String, dynamic> toMap() {
    return {
      'bingo_list': bingoList.map((e) => 
          (e as GameBingoContentItemModel).toMap()).toList(),
    };
  }

  Map<String, dynamic> toSeparatedArrays() {
    final questions = bingoList.map((e) => e.question).toList();
    final answers = bingoList.map((e) => e.answer).toList();
    final points = bingoList.map((e) => e.point).toList();

    return {
      'questions': questions,
      'answers': answers,
      'points': points,
    };
  }
}

class GameContentModel {
  static GameContentEntity fromMap(String gameType, Map<String, dynamic> map) {
    switch (gameType) {
      case 'quiz':
        return GameQuizContentModel.fromMap(map);
      case 'yesno':
        return GameYesNoContentModel.fromMap(map);
      case 'bingo':
        return BingoContentModel.fromMap(map);
      default:
        throw Exception('Unknown game type: $gameType');
    }
  }

  static Map<String, dynamic> toMap(GameContentEntity entity) {
    if (entity is GameQuizContentEntity) {
      return (entity as GameQuizContentModel).toMap();
    } else if (entity is GameYesNoContentEntity) {
      return (entity as GameYesNoContentModel).toMap();
    } else if (entity is BingoContentEntity) {
      return (entity as BingoContentModel).toMap();
    } else {
      throw Exception('Unknown game content type');
    }
  }
}

class GameModel extends GameEntity {
  const GameModel({
    required super.id,
    required super.gameType,
    required super.content,
  });

  factory GameModel.fromEntity(GameEntity entity) {
    return GameModel(
      id: entity.id,
      gameType: entity.gameType,
      content: entity.content,
    );
  }

  factory GameModel.fromMap(String id, Map<String, dynamic> map) {
    final gameType = map['game_type'] as String;
    final content = GameContentModel.fromMap(gameType, map['content'] as Map<String, dynamic>);

    return GameModel(
      id: id,
      gameType: gameType,
      content: content,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'game_type': gameType,
      'content': GameContentModel.toMap(content),
    };
  }
}

class PlayerHistoryModel extends PlayerHistoryEntity {
  const PlayerHistoryModel({
    required super.playerId,
    required super.score,
  });

  factory PlayerHistoryModel.fromEntity(PlayerHistoryEntity entity) {
    return PlayerHistoryModel(
      playerId: entity.playerId,
      score: entity.score,
    );
  }

  factory PlayerHistoryModel.fromMap(Map<String, dynamic> map) {
    return PlayerHistoryModel(
      playerId: map['player'] is DocumentReference 
          ? (map['player'] as DocumentReference).path
          : map['player'].toString(),
      score: map['score'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'player': playerId,
      'score': score,
    };
  }
}

class GamesTypeModel extends GamesTypeEntity {
  const GamesTypeModel({
    required super.id,
    required super.author,
    required super.name,
    required super.description,
    required super.icon,
    required super.gameList,
    required super.media,
    required super.playedHistory,
  });

  factory GamesTypeModel.fromEntity(GamesTypeEntity entity) {
    return GamesTypeModel(
      id: entity.id,
      author: entity.author,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      gameList: entity.gameList,
      media: entity.media,
      playedHistory: entity.playedHistory,
    );
  }

  factory GamesTypeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GamesTypeModel(
      id: doc.id,
      author: data['author'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '',
      media: data['media'] ?? '',
      gameList: _parseGameList(data['game_list']),
      playedHistory: _parsePlayedHistory(data['played_history']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'name': name,
      'description': description,
      'icon': icon,
      'media': media,
      'game_list': gameList.map((game) => 
          (game as GameModel).toMap()).toList(),
      'played_history': playedHistory.map((history) => 
          (history as PlayerHistoryModel).toMap()).toList(),
    };
  }

  static List<GameEntity> _parseGameList(dynamic gameListData) {
    if (gameListData is List) {
      return gameListData
          .map((game) => GameModel.fromMap(
              game['id'] ?? '', game as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<PlayerHistoryEntity> _parsePlayedHistory(dynamic historyData) {
    if (historyData is List) {
      return historyData
          .map((history) => PlayerHistoryModel.fromMap(
              history as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}