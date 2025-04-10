import 'package:cloud_firestore/cloud_firestore.dart';

class GameHistoryService {
  final CollectionReference history =
      FirebaseFirestore.instance.collection("history");

  /// Adds a new game record to the user's history.
  Future<void> addGameHistory({
    required String email,
    required DocumentReference gameId,
    required String gameName,
    // required int score,
  }) async {
    try {
      final userRef = history.doc(email);

      await userRef.update({
        'data': FieldValue.arrayUnion([
          {
            'game_id': gameId,
            'game_name': gameName,
            'best_score': 0,
            // 'image_game': imageGame,
            'played_at': Timestamp.now(),
          }
        ])
      });

      print("Game history added!");
    } catch (error) {
      print("Failed to add game history: $error");
    }
  }

  /// Retrieves the user's game history.
  Future<List<Map<String, dynamic>>> getGameHistory({
    required String email,
  }) async {
    try {
      final userDoc = await history.doc(email).get();

      if (!userDoc.exists) {
        print("User not found");
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData.containsKey('data')) {
        return List<Map<String, dynamic>>.from(userData['data']);
      }

      return [];
    } catch (error) {
      print("error: $error");
      return [];
    }
  }

  /// Removes a game from the user's history.
  Future<void> removeGameFromHistory({
    required String email,
    required DocumentReference gamePath,
  }) async {
    try {
      final userDoc = await history.doc(email).get();

      if (!userDoc.exists) {
        print("User history not found");
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      
      if (!userData.containsKey('data')) {
        print("No history data found");
        return;
      }
      
      List<dynamic> historyData = List<dynamic>.from(userData['data']);
      
      // Filter out entries with matching game_id
      historyData = historyData.where((entry) => 
        entry['game_id'] != gamePath
      ).toList();
      
      // Update the history document with filtered data
      await history.doc(email).update({
        'data': historyData
      });
      
      print("Game removed from history successfully");
    } catch (error) {
      print("Failed to remove game from history: $error");
    }
  }

  /// Updates the best score for a specific game in the user's history.
  Future<int> updateGameScore({
    required String email,
    required DocumentReference gameId,
    required int newScore,
  }) async {
    try {
      final userDoc = await history.doc(email).get();
      
      if (!userDoc.exists) {
        print("User history not found");
        return 0;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      if (!userData.containsKey('data')) {
        print("No history data found");
        return 0;
      }
      
      List<dynamic> historyData = List<dynamic>.from(userData['data']);
      int bestScore = 0;
      bool gameFound = false;
      
      // Find the game and update its best score
      for (var i = 0; i < historyData.length; i++) {
        if (historyData[i]['game_id'] == gameId) {
          gameFound = true;
          bestScore = historyData[i]['best_score'] ?? 0;
          
          // Update only if new score is higher
          if (newScore > bestScore) {
            historyData[i]['best_score'] = newScore;
            await history.doc(email).update({
              'data': historyData
            });
            bestScore = newScore;
          }
          break;
        }
      }
      
      // If game not found in history, add it with the current score
      if (!gameFound && gameId != null) {
        await addGameHistory(
          email: email,
          gameId: gameId,
          gameName: "Game", // Default name, consider fetching actual name
          // score: newScore,
        );
        bestScore = newScore;
      }
      
      return bestScore;
    } catch (error) {
      print("Failed to update game score: $error");
      return 0;
    }
  }
}
