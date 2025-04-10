import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithEmailPasswordEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailPasswordEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpWithEmailPasswordEvent extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailPasswordEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignInWithGoogleEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}