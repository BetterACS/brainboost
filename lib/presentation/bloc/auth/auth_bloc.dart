import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainboost/domain/usecases/auth/sign_in_with_email_password.dart';
import 'package:brainboost/domain/usecases/auth/sign_up_with_email_password.dart';
import 'package:brainboost/domain/usecases/auth/sign_in_with_google.dart';
import 'package:brainboost/domain/usecases/auth/sign_out.dart';
import 'package:brainboost/domain/repositories/auth_repository.dart';
import 'package:brainboost/presentation/bloc/auth/auth_event.dart';
import 'package:brainboost/presentation/bloc/auth/auth_state.dart';

class CheckAuthStatusEvent extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailPassword signInWithEmailPassword;
  final SignUpWithEmailPassword signUpWithEmailPassword;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInWithEmailPassword,
    required this.signUpWithEmailPassword,
    required this.signInWithGoogle,
    required this.signOut,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInWithEmailPasswordEvent>(_onSignInWithEmailPassword);
    on<SignUpWithEmailPasswordEvent>(_onSignUpWithEmailPassword);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSignInWithEmailPassword(
    SignInWithEmailPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithEmailPassword(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpWithEmailPassword(
    SignUpWithEmailPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpWithEmailPassword(
      SignUpParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOut();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await authRepository.getCurrentUser();
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
