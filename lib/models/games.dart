enum GameType {
  quiz,
}

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
  final GameType gameType;
  final GameContent content;

  const GameData({
    // required this.gameName,
    required this.gameType,
    required this.content,
  });
}
