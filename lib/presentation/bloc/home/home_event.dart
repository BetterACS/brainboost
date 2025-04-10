import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserDataEvent extends HomeEvent {
  final String email;

  const LoadUserDataEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class LoadGamePerformanceEvent extends HomeEvent {
  final String email;

  const LoadGamePerformanceEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class LoadHistoryEvent extends HomeEvent {
  final String email;

  const LoadHistoryEvent({required this.email});

  @override
  List<Object> get props => [email];
}