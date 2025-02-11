import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/models/games.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserServices {
  final CollectionReference users =
      FirebaseFirestore.instance.collection("users");

  /// Adds a new user to the Firestore collection.
  Future<void> addUser({required String email}) async {
    final username = email.split('@')[0];

    // Convert DateTime objects to Timestamps for Firestore.
    final userData = {
      'email': email,
      'icon': 'default',
      'username': username,
      'create_at': Timestamp.now(),
      'latest_login': Timestamp.now(),
      'age': 12,
      'game_sets': [],
    };

    // Use the id (converted to a string) as the document ID.
    await users
        .doc(email)
        .set(userData)
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  String? getCurrentUserEmail() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.email;
}

  Future<List<String>> getGames({
    required String email,
  }) async {
    try {
      final userDoc = await users.doc(email).get();
      if (!userDoc.exists) {
        print("User not found");
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData.containsKey('games')) {
        // Convert DocumentReference to string paths
        return (userData['games'] as List)
            .map((game) =>
                (game as DocumentReference).path) // Get path of each reference
            .toList();
      }

      return [];
    } catch (error) {
      print("Failed to get games: $error");
      return [];
    }
  }
  
}
