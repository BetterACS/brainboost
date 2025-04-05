import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/models/games.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      'games': [],
      'recent_play': null
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

  Future<String> getPersonalize({
    required String email,
  }) async {
    try {
      final userDoc = await users.doc(email).get();
      if (!userDoc.exists) {
        print("User not found");
        return "";
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      print(userData);
      // return as string.
      if (userData.containsKey('personalize')) {
        return userData['personalize'];
      }
      return "";

    } catch (error) {
      print("Failed to get games: $error");
      return "";
    }
  }
  
  Future<void> addSharedGame({required String email, required String gamePath}) async {
    try {
      // Get the current user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) {
        throw Exception('User not found');
      }
      
      final docId = userDoc.docs[0].id;
      
      // Get current games list
      List<dynamic> currentGames = userDoc.docs[0].data()['games'] ?? [];
      DocumentReference gameRef = FirebaseFirestore.instance.doc("/games/" + gamePath);

      // Check if game is already in user's collection
      if (currentGames.contains(gameRef)) {
        throw Exception('Game already in your collection');
      }
      
      // Add the new game path as a DocumentReference
      currentGames.add(gameRef);
      
      // Update the user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .update({'games': currentGames});
    } catch (e) {
      print('Error in addSharedGame: $e');
      throw e;
    }
  }
}
