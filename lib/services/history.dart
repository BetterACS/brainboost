import 'package:cloud_firestore/cloud_firestore.dart';

class GameHistoryService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection("history");

  /// Adds a new game record to the user's history.
  Future<void> addGameHistory({
    required String email,
    required String gameId,
    required String gameName,
    required int score,
  }) async {
    try {
      final userRef = users.doc(email);

      await userRef.update({
        'game_history': FieldValue.arrayUnion([
          {
            'game_id': gameId,
            'game_name': gameName,
            'score': score,
            'image_game': 'default',
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
      final userDoc = await users.doc(email).get();

      if (!userDoc.exists) {
        print("User not found");
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData.containsKey('game_history')) {
        return List<Map<String, dynamic>>.from(userData['game_history']);
      }

      return [];
    } catch (error) {
      print("error: $error");
      return [];
    }
  }
}
