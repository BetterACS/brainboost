import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

class UserDataLoaded extends HomeState {
  final String username;
  final String email;
  final String? profileImageUrl;

  const UserDataLoaded({
    required this.username,
    required this.email,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [username, email, profileImageUrl];
}

class GamePerformanceLoaded extends HomeState {
  final int totalGames;
  final int correctAnswers;
  final bool isLoaded;

  const GamePerformanceLoaded({
    required this.totalGames,
    required this.correctAnswers,
    required this.isLoaded,
  });

  double get successRate => 
    totalGames > 0 ? (correctAnswers / totalGames) * 100 : 0;

  @override
  List<Object> get props => [totalGames, correctAnswers, isLoaded];
}

class HistoryLoaded extends HomeState {
  final List<Map<String, dynamic>> historyItems;

  const HistoryLoaded(this.historyItems);

  @override
  List<Object> get props => [historyItems];
}

class HomeLoadComplete extends HomeState {
  final String username;
  final String email;
  final String? profileImageUrl;
  final int totalGames;
  final int correctAnswers;
  final List<Map<String, dynamic>> historyItems;

  const HomeLoadComplete({
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.totalGames,
    required this.correctAnswers,
    required this.historyItems,
  });

  double get successRate => 
    totalGames > 0 ? (correctAnswers / totalGames) * 100 : 0;

  @override
  List<Object?> get props => [
    username, 
    email, 
    profileImageUrl, 
    totalGames, 
    correctAnswers, 
    historyItems
  ];
}