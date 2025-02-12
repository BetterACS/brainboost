import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/models/games.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GameServices {
  final CollectionReference games =
      FirebaseFirestore.instance.collection("games");

  /// Adds a new user to the Firestore collection.
  Future<Object> getGame({
    required String path,
  }) async {
    // Use the id (converted to a string) as the document ID.
    final Object game = await FirebaseFirestore.instance
        .doc(path)
        .get()
        .then((value) => value.data())
        .catchError((error) => print("Failed to get game: $error")) as Object;

    return game;
  }

  Future<DocumentReference?> createGame({
    required String name,
    required String email,
    required List<dynamic> gameData,
  }) async {
    try {
      DocumentReference docID = await games
          .add({
            'name': name,
            'author': email,
            'description': "This is a game",
            'icon': "photomain.png",
            'media': "media.png",
            'game_list': gameData,
          })
          .then((value) => value)
          .catchError((error) => print("Failed to create game: $error"));
      return docID;
    } catch (error) {
      print("Failed to create game: $error");
      return null;
    }
  }

  Future<void> addGameToUser({
    required String email,
    required DocumentReference docPath,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .update({
            'games': FieldValue.arrayUnion([docPath]),
          })
          .then((value) => print("Game added to user"))
          .catchError((error) => print("Failed to add game to user: $error"));
    } catch (error) {
      print("Failed to add game to user: $error");
    }
  }

  Future<void> deleteGame({required String path, required String email}) async {
    print("Start remove");
    final userRef = FirebaseFirestore.instance.collection("users").doc(email);

    try {
      // Fetch the current games array
      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        print("User document does not exist!");
        return;
      }

      List<dynamic> games = snapshot.data()?['games'] ?? [];

      print("Current games: $games");

      // Check if the path exists in the array
      DocumentReference<Map<String, dynamic>> gamePath =
          FirebaseFirestore.instance.doc(path);

      if (!games.contains(gamePath)) {
        print("Game path not found: $gamePath");
        return;
      }

      // Remove the game path
      await userRef.update({
        'games': FieldValue.arrayRemove([gamePath]),
      });

      print("Delete Game: $gamePath");
    } catch (error) {
      print("Failed to delete reference game: $error");
    }
  }

  // Future<void> deleteGame({required String path, required String email}) async {
  //   print("Start remove");
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(email)
  //         .update({
  //           'games': FieldValue.arrayRemove(["/" + path]),
  //         })
  //         .then((value) => print("Delete Game"))
  //         .catchError((error) => print("Failed to add game to user: $error"));
  //   } catch (error) {
  //     print("Failed to delete reference game $error");
  //     return;
  //   }

  //   // try {
  //   //   await FirebaseFirestore.instance.doc(path as String).delete();
  //   // } catch (error) {
  //   //   print("Failed to delete game $error");
  //   // }

  //   // await FirebaseFirestore.instance.collection("users").doc(email).update(
  //   //   'games': ...
  //   // );
  // }

  Future<void> addStoreToPlayedHistory({
    required String email,
    required String gamePath,
    required int score,
  }) async {
    try {
      DocumentReference gameRef = FirebaseFirestore.instance.doc(gamePath);

      // Get current played history
      DocumentSnapshot gameSnapshot = await gameRef.get();

      if (!gameSnapshot.exists) {
        print("Game document does not exist");
        return;
      }

      List<dynamic> playedHistory =
          (gameSnapshot.data() as Map<String, dynamic>)["played_history"] ?? [];

      // Create new score entry
      Map<String, dynamic> scoreMap = {
        "player": FirebaseFirestore.instance.collection("users").doc(email),
        "score": score
      };

      // Add new entry
      playedHistory.add(scoreMap);

      // Keep only the last 5 entries
      if (playedHistory.length > 5) {
        playedHistory.removeAt(0); // Remove the oldest entry (first element)
      }

      // Update Firestore
      await gameRef.update({"played_history": playedHistory});

      print("Added to played history");
    } catch (error) {
      print("Failed to add score: $error");
    }
  }
}
