import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/domain/repositories/user_repository.dart';
import 'package:brainboost/domain/repositories/game_repository.dart';
import 'package:brainboost/data/datasources/remote/firebase_user_datasource.dart';
import 'package:brainboost/presentation/bloc/home/home_event.dart';
import 'package:brainboost/presentation/bloc/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;
  final GameRepository gameRepository;
  final FirebaseUserDataSource userDataSource;
  final FirebaseFirestore firestore;

  HomeBloc({
    required this.userRepository,
    required this.gameRepository,
    required this.userDataSource,
    required this.firestore,
  }) : super(HomeInitial()) {
    on<LoadUserDataEvent>(_onLoadUserData);
    on<LoadGamePerformanceEvent>(_onLoadGamePerformance);
    on<LoadHistoryEvent>(_onLoadHistory);
  }

  Future<void> _onLoadUserData(
    LoadUserDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final result = await userRepository.getUserProfile(email: event.email);
      
      result.fold(
        (failure) => emit(HomeError(failure.message)),
        (user) {
          emit(UserDataLoaded(
            username: user.username,
            email: user.email,
            profileImageUrl: user.icon,
          ));
          
          // Chain next events
          add(LoadGamePerformanceEvent(email: event.email));
          add(LoadHistoryEvent(email: event.email));
        },
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadGamePerformance(
    LoadGamePerformanceEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Get user games first
      final gamesResult = await userRepository.getUserGames(email: event.email);
      
      return gamesResult.fold(
        (failure) => emit(HomeError(failure.message)),
        (gamePaths) async {
          int totalGames = 0;
          int correctAnswers = 0;
          
          // For each game, get game data and calculate performance
          for (final gamePath in gamePaths) {
            try {
              DocumentReference gameRef = firestore.doc(gamePath);
              DocumentSnapshot gameSnap = await gameRef.get();
              
              if (!gameSnap.exists) continue;
              
              Map<String, dynamic> gameData = gameSnap.data() as Map<String, dynamic>;
              
              // Count total questions in the game
              if (gameData.containsKey('game_list')) {
                List<dynamic> gameList = gameData['game_list'] as List<dynamic>;
                totalGames += gameList.length;
              }
              
              // Get player scores
              if (gameData.containsKey('played_history')) {
                List<dynamic> playedHistory = gameData['played_history'] as List<dynamic>;
                
                for (final history in playedHistory) {
                  DocumentReference playerRef = history['player'] as DocumentReference;
                  String playerEmail = playerRef.path.split('/').last;
                  
                  if (playerEmail == event.email) {
                    int score = history['score'] as int;
                    correctAnswers += score;
                    break; // Only count the user's score once per game
                  }
                }
              }
            } catch (e) {
              print('Error processing game $gamePath: $e');
            }
          }
          
          // Get the current state to check if we have user data loaded
          if (state is UserDataLoaded) {
            final userState = state as UserDataLoaded;
            emit(HomeLoadComplete(
              username: userState.username,
              email: userState.email,
              profileImageUrl: userState.profileImageUrl,
              totalGames: totalGames,
              correctAnswers: correctAnswers,
              historyItems: [], // Will be filled by history event
            ));
          } else {
            emit(GamePerformanceLoaded(
              totalGames: totalGames,
              correctAnswers: correctAnswers,
              isLoaded: true,
            ));
          }
        },
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Get history from Firestore directly
      final historyDoc = await firestore
          .collection('history')
          .doc(event.email)
          .get();
          
      if (!historyDoc.exists) {
        emit(const HistoryLoaded([]));
        return;
      }
      
      final historyData = historyDoc.data() as Map<String, dynamic>?;
      if (historyData == null || !historyData.containsKey('data')) {
        emit(const HistoryLoaded([]));
        return;
      }
      
      final historyItems = (historyData['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();
      
      // If we have user data and performance data, emit complete state
      if (state is UserDataLoaded || state is GamePerformanceLoaded || state is HomeLoadComplete) {
        HomeState currentState = state;
        String username = '';
        String email = '';
        String? profileImageUrl;
        int totalGames = 0;
        int correctAnswers = 0;
        
        if (currentState is UserDataLoaded) {
          username = (currentState as UserDataLoaded).username;
          email = (currentState as UserDataLoaded).email;
          profileImageUrl = (currentState as UserDataLoaded).profileImageUrl;
        } else if (currentState is GamePerformanceLoaded) {
          totalGames = (currentState as GamePerformanceLoaded).totalGames;
          correctAnswers = (currentState as GamePerformanceLoaded).correctAnswers;
        } else if (currentState is HomeLoadComplete) {
          username = (currentState as HomeLoadComplete).username;
          email = (currentState as HomeLoadComplete).email;
          profileImageUrl = (currentState as HomeLoadComplete).profileImageUrl;
          totalGames = (currentState as HomeLoadComplete).totalGames;
          correctAnswers = (currentState as HomeLoadComplete).correctAnswers;
        }
        
        emit(HomeLoadComplete(
          username: username,
          email: email,
          profileImageUrl: profileImageUrl,
          totalGames: totalGames,
          correctAnswers: correctAnswers,
          historyItems: historyItems,
        ));
      } else {
        emit(HistoryLoaded(historyItems));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}