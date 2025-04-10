import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/core/errors/exceptions.dart';
import 'package:brainboost/data/models/game_model.dart';

abstract class FirebaseGameDataSource {
  /// Get all games
  Future<List<GamesTypeModel>> getAllGames();
  
  /// Get game by ID
  Future<GamesTypeModel> getGameById(String id);
  
  /// Create new game
  Future<String> createGame(GamesTypeModel game);
  
  /// Update game
  Future<void> updateGame(GamesTypeModel game);
  
  /// Delete game
  Future<void> deleteGame(String id);
  
  /// Get user games
  Future<List<GamesTypeModel>> getUserGames(String email);
  
  /// Add player history
  Future<void> addPlayerHistory({
    required String gameId,
    required String playerId,
    required int score,
  });
}

class FirebaseGameDataSourceImpl implements FirebaseGameDataSource {
  final FirebaseFirestore firestore;

  FirebaseGameDataSourceImpl({required this.firestore});

  @override
  Future<List<GamesTypeModel>> getAllGames() async {
    try {
      final querySnapshot = await firestore.collection('games').get();
      
      return querySnapshot.docs
          .map((doc) => GamesTypeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get games: ${e.toString()}');
    }
  }

  @override
  Future<GamesTypeModel> getGameById(String id) async {
    try {
      final doc = await firestore.collection('games').doc(id).get();
      
      if (!doc.exists) {
        throw ServerException('Game not found');
      }
      
      return GamesTypeModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get game: ${e.toString()}');
    }
  }

  @override
  Future<String> createGame(GamesTypeModel game) async {
    try {
      final docRef = await firestore.collection('games').add(game.toMap());
      return docRef.id;
    } catch (e) {
      throw ServerException('Failed to create game: ${e.toString()}');
    }
  }

  @override
  Future<void> updateGame(GamesTypeModel game) async {
    try {
      await firestore.collection('games').doc(game.id).update(game.toMap());
    } catch (e) {
      throw ServerException('Failed to update game: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteGame(String id) async {
    try {
      await firestore.collection('games').doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete game: ${e.toString()}');
    }
  }

  @override
  Future<List<GamesTypeModel>> getUserGames(String email) async {
    try {
      // Get user document to retrieve game references
      final userDoc = await firestore.collection('users').doc(email).get();
      
      if (!userDoc.exists) {
        throw ServerException('User not found');
      }
      
      final userData = userDoc.data()!;
      
      if (!userData.containsKey('games') || (userData['games'] as List).isEmpty) {
        return [];
      }
      
      // Get references to games
      final gameRefs = (userData['games'] as List)
          .map((game) => game as DocumentReference)
          .toList();
      
      // Fetch each game document
      final gamesList = <GamesTypeModel>[];
      for (final ref in gameRefs) {
        final gameDoc = await ref.get();
        if (gameDoc.exists) {
          gamesList.add(GamesTypeModel.fromFirestore(gameDoc));
        }
      }
      
      return gamesList;
    } catch (e) {
      throw ServerException('Failed to get user games: ${e.toString()}');
    }
  }

  @override
  Future<void> addPlayerHistory({
    required String gameId,
    required String playerId,
    required int score,
  }) async {
    try {
      // Get the game document
      final gameDoc = await firestore.collection('games').doc(gameId).get();
      
      if (!gameDoc.exists) {
        throw ServerException('Game not found');
      }
      
      // Get current history
      final data = gameDoc.data()!;
      final List<dynamic> history = data.containsKey('played_history')
          ? List.from(data['played_history'])
          : [];
      
      // Add new history entry
      history.add({
        'player': firestore.doc(playerId),
        'score': score,
      });
      
      // Update game document
      await firestore.collection('games').doc(gameId).update({
        'played_history': history,
      });
      
      // Also update user's history collection
      final playerDoc = await firestore.collection('history').doc(playerId.split('/').last).get();
      
      if (playerDoc.exists) {
        final historyData = playerDoc.data()!;
        final List<dynamic> userHistory = historyData.containsKey('data')
            ? List.from(historyData['data'])
            : [];
        
        // Add new entry with timestamp
        userHistory.add({
          'game': firestore.doc('games/$gameId'),
          'score': score,
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        // Update history document
        await firestore.collection('history').doc(playerId.split('/').last).update({
          'data': userHistory,
        });
      }
    } catch (e) {
      throw ServerException('Failed to add player history: ${e.toString()}');
    }
  }
}