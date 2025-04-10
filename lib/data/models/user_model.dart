import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.email,
    required super.username,
    required super.icon,
    required super.createdAt,
    required super.latestLogin,
    required super.age,
    required super.games,
    super.recentPlay,
    required super.settings,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      email: entity.email,
      username: entity.username,
      icon: entity.icon,
      createdAt: entity.createdAt,
      latestLogin: entity.latestLogin,
      age: entity.age,
      games: entity.games,
      recentPlay: entity.recentPlay,
      settings: entity.settings,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      icon: data['icon'] ?? 'default',
      createdAt: (data['create_at'] as Timestamp).toDate(),
      latestLogin: (data['latest_login'] as Timestamp).toDate(),
      age: data['age'] ?? 18,
      games: _parseGames(data['games']),
      recentPlay: data['recent_play'],
      settings: data['Setting'] ?? {'Theme': 'light', 'Language': 'en'},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'icon': icon,
      'create_at': Timestamp.fromDate(createdAt),
      'latest_login': Timestamp.fromDate(latestLogin),
      'age': age,
      'games': games,
      'recent_play': recentPlay,
      'Setting': settings,
    };
  }

  static List<String> _parseGames(dynamic gamesData) {
    if (gamesData is List) {
      return gamesData
          .map((game) => 
            (game is DocumentReference) 
              ? game.path 
              : game.toString())
          .toList();
    }
    return [];
  }
}