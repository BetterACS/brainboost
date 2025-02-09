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
    final Object game = await FirebaseFirestore.instance.doc(path).get().then((value) => value.data()).catchError((error) => print("Failed to get game: $error")) as Object;

    return game;
  }

  Future<DocumentReference?> createGame({
    required String name,
    required String email,
    required List<dynamic> gameData,
  }) async {
    try {

      DocumentReference docID = await games.add({
        'name': name,
        'author': email,
        'description': "This is a game",
        'icon': "photomain.png",
        'media': "media.png",
        'game_list': gameData,
      }).then((value) => value).catchError((error) => print("Failed to create game: $error"));
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
      await FirebaseFirestore.instance.collection("users").doc(email).update({
        'games': FieldValue.arrayUnion([docPath]),
      }).then((value) => print("Game added to user")).catchError((error) => print("Failed to add game to user: $error"));
    } catch (error) {
      print("Failed to add game to user: $error");
    }
  }
}
