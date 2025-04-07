import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

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

class GameYesNoContent extends GameContent {
  final String question;
  final bool correct_ans;

  const GameYesNoContent({
    required this.correct_ans,
    required this.question,
  }) : super();

  // เพิ่มเมธอด toMap()
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'correct_ans': correct_ans,
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
      case 'yesno':
        return GameYesNoContent(
          correct_ans: content['correct_ans'] as bool,
          question: content['question'] as String,
        );
      case 'bingo':
        print("Bingo ${content}");
        
        // Check if data is in the new format (separate arrays)
        if (content.containsKey('questions') && content.containsKey('answers')) {
          final questions = (content['questions'] as List<dynamic>).map((e) => e as String).toList();
          final answers = (content['answers'] as List<dynamic>).map((e) => e as String).toList();
          
          // Generate random points if not provided
          List<int> points = [];
          if (content.containsKey('points')) {
            points = (content['points'] as List<dynamic>).map((e) => e as int).toList();
          } else {
            // Generate random points between 10-15
            final random = Random();
            for (int i = 0; i < questions.length; i++) {
              points.add(random.nextInt(6) + 10); // 10-15 range
            }
          }
          
          return BingoContent.fromArrays(
            questions: questions,
            answers: answers,
            points: points,
          );
        } 
        // If using old format with bingo_list
        else if (content.containsKey('bingo_list')) {
          return BingoContent(
            bingo_list: (content['bingo_list'] as List<dynamic>)
                .map((e) => GameBingoContent(
                    answer: e['answer'],
                    point: e['point'],
                    question: e['question']))
                .toList());
        }
        // Default empty bingo content if format is unrecognized
        return BingoContent(bingo_list: []);

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

  factory BingoContent.fromArrays({
    required List<String> questions,
    required List<String> answers,
    List<int>? points,
  }) {
    // Validate that questions and answers have the same length
    if (questions.length != answers.length) {
      throw ArgumentError('Questions and answers must have the same length');
    }

    // Generate random points if not provided
    final actualPoints = points ?? List.generate(
      questions.length, 
      (_) => Random().nextInt(11) + 10  // Random points between 10-15
    );

    // Validate that points list has the same length as questions/answers
    if (actualPoints.length != questions.length) {
      throw ArgumentError('Points list must have the same length as questions and answers');
    }

    List<GameBingoContent> bingoList = [];
    for (int i = 0; i < questions.length; i++) {
      bingoList.add(GameBingoContent(
        question: questions[i],
        answer: answers[i],
        point: actualPoints[i],
      ));
    }
    return BingoContent(bingo_list: bingoList);
  }

  Map<String, dynamic> toMap() {
    return {
      'bingo_list': bingo_list.map((e) => e.toMap()).toList(),
    };
  }

  /// Create separate arrays for questions, answers, and points
  Map<String, dynamic> toSeparatedArrays() {
    List<String> questions = bingo_list.map((e) => e.question).toList();
    List<String> answers = bingo_list.map((e) => e.answer).toList();
    List<int> points = bingo_list.map((e) => e.point).toList();

    return {
      'questions': questions,
      'answers': answers,
      'points': points,
    };
  }
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

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'point': point,
    };
  }
}
