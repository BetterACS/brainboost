import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String email;
  final String username;
  final String icon;
  final DateTime createdAt;
  final DateTime latestLogin;
  final int age;
  final List<String> games;
  final String? recentPlay;
  final Map<String, dynamic> settings;

  const UserEntity({
    required this.email,
    required this.username,
    required this.icon,
    required this.createdAt,
    required this.latestLogin,
    required this.age,
    required this.games,
    this.recentPlay,
    required this.settings,
  });

  @override
  List<Object?> get props => [
        email,
        username,
        icon,
        createdAt,
        latestLogin,
        age,
        games,
        recentPlay,
        settings,
      ];
}