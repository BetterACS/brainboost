import 'package:cloud_firestore/cloud_firestore.dart';

class GameContent {
  const GameContent();
}

class GameQuizContent extends GameContent {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  const GameQuizContent({
    required this.correctAnswerIndex,
    required this.question,
    required this.options,
  }) : super();
}

class GameData {
  // final String gameName;
  final String gameType;
  final GameContent content;

  const GameData({
    // required this.gameName,
    required this.gameType,
    required this.content,
  });
}

class PlayerHistory {
  final DocumentReference player;
  final int score;

  const PlayerHistory({
    required this.player,
    required this.score
  });
}

class GamesType {
  final dynamic ref;
  final String author;
  final String name;
  final String description;
  final String icon;
  final List<Map<String, dynamic>> gameList;
  final String media;
  final List<Map<String, dynamic>> played_history;

  GamesType({
    required this.ref,
    required this.author,
    required this.name,
    required this.description,
    required this.icon,
    required this.gameList,
    required this.media,
    required this.played_history
  });

  /// Factory constructor to create a GamesType instance from Firestore data
  factory GamesType.fromMap(Map<String, dynamic> data, dynamic ref) {
    print(ref);
    return GamesType(
      ref: ref,
      author: data['author'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '',
      media: data['media'] ?? '',
      gameList: (data['game_list'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      played_history: (data['played_history'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}
