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

  // เพิ่มเมธอด toMap()
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'choices': options,
      'correct_idx': correctAnswerIndex,
    };
  }
}

class GameData {
  final String gameType;
  final GameContent content;
  const GameData({
    required this.gameType,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'game_type': gameType,
      'content': content is GameQuizContent 
        ? (content as GameQuizContent).toMap() 
        : content
    };
  }

  static GameContent createContent(
      String gameType, Map<String, dynamic> content) {
    switch (gameType) {
      case 'quiz':
        return GameQuizContent(
          correctAnswerIndex: content['correct_idx'] as int,
          question: content['question'] as String,
          options: (content['choices'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
        );
      case 'bingo':

        //     question;
        // final String answer;
        // final int point;
        print("Bingo ${content}");

        return BingoContent(
            bingo_list: (content['bingo_list'] as List<dynamic>)
                .map((e) => GameBingoContent(
                    answer: e['answer'],
                    point: e['point'],
                    question: e['question']))
                .toList());

      default:
        return GameContent();
    }
  }
}

class PlayerHistory {
  final DocumentReference player;
  final int score;

  const PlayerHistory({required this.player, required this.score});
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

  GamesType(
      {required this.ref,
      required this.author,
      required this.name,
      required this.description,
      required this.icon,
      required this.gameList,
      required this.media,
      required this.played_history});

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

class BingoContent extends GameContent {
  final List<GameBingoContent> bingo_list;

  const BingoContent({required this.bingo_list}) : super();
}

class GameBingoContent {
  final String question;
  final String answer;
  final int point;

  const GameBingoContent({
    required this.question,
    required this.answer,
    required this.point,
  }) : super();
}

final List<GameBingoContent> bingoQuestions = [
  GameBingoContent(
      question: "What is the capital of France?", answer: "Paris", point: 10),
  GameBingoContent(
      question: "How many continents are there?", answer: "7", point: 10),
  GameBingoContent(question: "What is 5 + 3?", answer: "8", point: 5),
  GameBingoContent(
      question: "Who wrote 'Romeo and Juliet'?",
      answer: "Shakespeare",
      point: 15),
  GameBingoContent(
      question: "What is the boiling point of water?",
      answer: "100°C",
      point: 10),
  GameBingoContent(
      question: "Which planet is known as the Red Planet?",
      answer: "Mars",
      point: 10),
  GameBingoContent(
      question: "What is the square root of 64?", answer: "8", point: 10),
  GameBingoContent(
      question: "What is the largest ocean on Earth?",
      answer: "Pacific",
      point: 15),
  GameBingoContent(
      question: "Who painted the Mona Lisa?",
      answer: "Leonardo da Vinci",
      point: 20),
];

// class GameData2 {
//   final String gametype;
//   final GameContent content;
//   final String point;

//   const GameData2({
//     required this.gametype,
//     required this.content,
//     required this.point,
//   });

//   static GameContent createContent(
//       String gameType, Map<String, dynamic> content) {
//     switch (gameType) {
//       case 'Bingo':
//         return GameBingoContent(
//           question: content['Question'] as String,
//           answer: content['answer'] as String,
//           point: int.parse(content['point']),
//         );
//       default:
//         return GameContent();
//     }
//   }
// }
