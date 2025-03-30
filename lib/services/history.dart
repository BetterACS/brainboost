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
}
