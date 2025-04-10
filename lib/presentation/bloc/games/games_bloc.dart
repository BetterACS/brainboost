import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:brainboost/domain/usecases/game/get_all_games.dart';
import 'package:brainboost/domain/usecases/game/get_user_games.dart';
import 'package:brainboost/domain/repositories/game_repository.dart';
import 'package:brainboost/domain/repositories/user_repository.dart';
import 'package:brainboost/presentation/bloc/games/games_event.dart';
import 'package:brainboost/presentation/bloc/games/games_state.dart';
import 'package:brainboost/data/models/game_model.dart';
import 'package:brainboost/core/errors/failures.dart';
import 'dart:io';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  final GetAllGames getAllGames;
  final GetUserGames getUserGames;
  final GameRepository gameRepository;
  final UserRepository userRepository;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  GamesBloc({
    required this.getAllGames,
    required this.getUserGames,
    required this.gameRepository,
    required this.userRepository,
    required this.firestore,
    required this.storage,
  }) : super(GamesInitial()) {
    on<GetAllGamesEvent>(_onGetAllGames);
    on<GetGameByIdEvent>(_onGetGameById);
    on<GetUserGamesEvent>(_onGetUserGames);
    on<CreateGameEvent>(_onCreateGame);
    on<UpdateGameEvent>(_onUpdateGame);
    on<DeleteGameEvent>(_onDeleteGame);
    on<AddPlayerHistoryEvent>(_onAddPlayerHistory);
    on<AddSharedGameEvent>(_onAddSharedGame);
    on<UpdateGameNameEvent>(_onUpdateGameName);
    on<UpdateGameIconEvent>(_onUpdateGameIcon);
    on<UploadFileEvent>(_onUploadFile);
    on<CreateGameFromPdfEvent>(_onCreateGameFromPdf);
    on<AddLectureToGameEvent>(_onAddLectureToGame);
  }

  Future<void> _onGetAllGames(
    GetAllGamesEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    final result = await getAllGames();
    result.fold(
      (failure) => emit(GamesError(failure.message)),
      (games) => emit(AllGamesLoaded(games)),
    );
  }

  Future<void> _onGetGameById(
    GetGameByIdEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    final result = await gameRepository.getGameById(event.id);
    result.fold(
      (failure) => emit(GamesError(failure.message)),
      (game) => emit(SingleGameLoaded(game)),
    );
  }

  Future<void> _onGetUserGames(
    GetUserGamesEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    try {
      // Get user games paths
      final pathsResult = await userRepository.getUserGames(email: event.email);
      
      return pathsResult.fold(
        (failure) => emit(GamesError(failure.message)),
        (paths) async {
          final games = <GamesTypeModel>[];
          
          // Fetch each game document
          for (final path in paths) {
            try {
              DocumentSnapshot doc = await firestore.doc(path).get();
              if (doc.exists) {
                games.add(GamesTypeModel.fromFirestore(doc));
              }
            } catch (e) {
              print('Error fetching game at $path: $e');
            }
          }
          
          emit(UserGamesLoaded(games));
        }
      );
    } catch (e) {
      emit(GamesError(e.toString()));
    }
  }

  Future<void> _onCreateGame(
    CreateGameEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    final result = await gameRepository.createGame(event.game);
    result.fold(
      (failure) => emit(GamesError(failure.message)),
      (id) => emit(GameCreated(id)),
    );
  }

  Future<void> _onUpdateGame(
    UpdateGameEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    final result = await gameRepository.updateGame(event.game);
    result.fold(
      (failure) => emit(GamesError(failure.message)),
      (_) => emit(GameUpdated()),
    );
  }

  Future<void> _onDeleteGame(
    DeleteGameEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    
    try {
      // First remove from user's games array
      await firestore.collection('users').doc(event.userEmail).update({
        'games': FieldValue.arrayRemove([firestore.doc(event.id)])
      });
      
      // Then delete the game document
      final result = await gameRepository.deleteGame(event.id);
      
      // Also remove from history if exists
      await firestore.collection('history').doc(event.userEmail).get().then((doc) {
        if (doc.exists) {
          final historyData = doc.data() as Map<String, dynamic>?;
          if (historyData != null && historyData.containsKey('data')) {
            final List<dynamic> history = List.from(historyData['data']);
            final filteredHistory = history.where((item) => 
              item['game_id'] != firestore.doc(event.id)
            ).toList();
            
            firestore.collection('history').doc(event.userEmail).update({
              'data': filteredHistory
            });
          }
        }
      });
      
      result.fold(
        (failure) => emit(GamesError(failure.message)),
        (_) => emit(GameDeleted()),
      );
    } catch (e) {
      emit(GamesError(e.toString()));
    }
  }

  Future<void> _onAddPlayerHistory(
    AddPlayerHistoryEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    final result = await gameRepository.addPlayerHistory(
      gameId: event.gameId,
      playerId: event.playerId,
      score: event.score,
    );
    result.fold(
      (failure) => emit(GamesError(failure.message)),
      (_) => emit(PlayerHistoryAdded()),
    );
  }

  Future<void> _onAddSharedGame(
    AddSharedGameEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    final result = await userRepository.addSharedGame(
      email: event.email,
      gamePath: event.gamePath,
    );
    result.fold(
      (failure) => emit(GamesError(failure.message)),
      (_) => emit(SharedGameAdded()),
    );
  }

  Future<void> _onUpdateGameName(
    UpdateGameNameEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    
    try {
      // Update the game name in Firestore
      await firestore.doc(event.gamePath).update({
        'name': event.newName
      });
      
      // Update history records if they exist
      if (event.userEmail != null) {
        await firestore.collection('history').doc(event.userEmail).get().then((doc) {
          if (doc.exists) {
            final historyData = doc.data() as Map<String, dynamic>?;
            if (historyData != null && historyData.containsKey('data')) {
              final List<dynamic> history = List.from(historyData['data']);
              final updatedHistory = history.map((item) {
                if (item['game_id'] == firestore.doc(event.gamePath)) {
                  return {
                    ...item,
                    'game_name': event.newName, 
                  };
                }
                return item;
              }).toList();
              
              firestore.collection('history').doc(event.userEmail).update({
                'data': updatedHistory
              });
            }
          }
        });
      }
      
      emit(GameNameUpdated(event.newName));
    } catch (e) {
      emit(GamesError('Failed to update game name: $e'));
    }
  }

  Future<void> _onUpdateGameIcon(
    UpdateGameIconEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    
    try {
      // Update the game icon in Firestore
      await firestore.doc(event.gamePath).update({
        'icon': event.newIcon
      });
      
      emit(GameIconUpdated(event.newIcon));
    } catch (e) {
      emit(GamesError('Failed to update game icon: $e'));
    }
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(FileUploading(0.0));
    
    try {
      final path = 'files/${event.fileName}';
      final ref = storage.ref().child(path);
      
      final uploadTask = ref.putFile(event.file);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        emit(FileUploading(progress));
      });
      
      await uploadTask.whenComplete(() {});
      
      final downloadUrl = await ref.getDownloadURL();
      emit(FileUploaded(downloadUrl));
    } catch (e) {
      emit(GamesError('Failed to upload file: $e'));
    }
  }

  Future<void> _onCreateGameFromPdf(
    CreateGameFromPdfEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    
    try {
      // Generate default icon
      final icons = ['animations/map1.GIF', 'animations/map2.GIF'];
      final icon = icons[DateTime.now().millisecondsSinceEpoch % icons.length];
      
      // Create game document
      final docRef = await firestore.collection('games').add({
        'name': event.gameName,
        'author': event.userEmail,
        'description': 'Generated from PDF',
        'icon': icon,
        'media': event.pdfUrl,
        'game_list': event.gameData ?? [],
        'played_history': [],
      });
      
      // Add game to user's games
      await firestore.collection('users').doc(event.userEmail).update({
        'games': FieldValue.arrayUnion([docRef])
      });
      
      emit(GameCreated(docRef.id));
    } catch (e) {
      emit(GamesError('Failed to create game: $e'));
    }
  }

  Future<void> _onAddLectureToGame(
    AddLectureToGameEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    
    try {
      // Get current game data
      final gameDoc = await firestore.doc(event.gamePath).get();
      if (!gameDoc.exists) {
        emit(GamesError('Game not found'));
        return;
      }
      
      final gameData = gameDoc.data() as Map<String, dynamic>;
      final List<dynamic> currentGameList = List.from(gameData['game_list'] ?? []);
      
      // Add new game data
      final List<dynamic> updatedGameList = List.from(currentGameList);
      if (event.newGameData != null) {
        updatedGameList.addAll(event.newGameData!);
      }
      
      // Update game document
      await firestore.doc(event.gamePath).update({
        'game_list': updatedGameList,
        'additional_media': FieldValue.arrayUnion([event.pdfUrl]),
      });
      
      emit(GameUpdated());
    } catch (e) {
      emit(GamesError('Failed to add lecture to game: $e'));
    }
  }
}