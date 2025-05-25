import 'package:flutter/material.dart';
import 'package:brainboost/services/user.dart';
import 'package:brainboost/services/games.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController extends ChangeNotifier {
  final UserServices _userServices = UserServices();
  final GameServices _gameServices = GameServices();

  bool _isProfileLoaded = false;
  bool get isProfileLoaded => _isProfileLoaded;

  bool _isLoadCircle = false;
  bool get isLoadCircle => _isLoadCircle;

  int _numberGames = 0;
  int get numberGames => _numberGames;

  int _correctQuestion = 0;
  int get correctQuestion => _correctQuestion;

  String _username = 'Loading...'; // Added from _HomeState's context
  String get username => _username;

  DocumentSnapshot? _userDoc; // To store user document for username
  DocumentSnapshot? get userDoc => _userDoc;

  // Method to fetch username, adapted from _HomeState
  Future<void> fetchUsername() async {
    final String? email = _userServices.getCurrentUserEmail();
    if (email == null) {
      _username = 'Guest';
      _isProfileLoaded = true;
      notifyListeners();
      return;
    }
    _userDoc = await _userServices.users.doc(email).get();
    if (_userDoc != null && _userDoc!.exists) {
        // Explicitly cast to Map<String, dynamic>
        final data = _userDoc!.data() as Map<String, dynamic>?;
        _username = data?['username'] ?? 'No username';
    } else {
        _username = 'No data';
    }
    _isProfileLoaded = true;
    notifyListeners();
  }

  // Method to fetch game performance, adapted from _HomeState
  Future<void> fetchGamePerformance() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || _isLoadCircle == true) return;

    List<String> gamesPath = await _userServices.getGames(email: email);
    int tempGames = 0;
    int tempScore = 0;

    for (String gamePath in gamesPath) {
      Map<String, dynamic>? game =
          await _gameServices.getGame(path: gamePath) as Map<String, dynamic>?;

      if (game == null || game['played_history'] == null) continue;

      int currentScore = 0;
      for (Map<String, dynamic> playedHistory in game['played_history']) {
        DocumentReference userPathRef = playedHistory['player'];
        String playerEmail = userPathRef.path.split("/")[1];

        if (playerEmail == email) {
          if (playedHistory['score'] > currentScore) {
            currentScore = playedHistory['score'];
          }
        }
      }
      
      if (game['game_list'] != null) {
        tempGames += (game['game_list'] as List).length;
      }
      tempScore += currentScore;
    }

    _isLoadCircle = true;
    _numberGames = tempGames;
    _correctQuestion = tempScore;
    notifyListeners();
  }
}
