import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/models/games.dart';

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
}
