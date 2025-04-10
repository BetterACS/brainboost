import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainboost/data/datasources/remote/firebase_user_datasource.dart';
import 'package:brainboost/domain/usecases/user/get_user_profile.dart';
import 'package:brainboost/domain/repositories/user_repository.dart';
import 'package:brainboost/presentation/bloc/profile/profile_event.dart';
import 'package:brainboost/presentation/bloc/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UserRepository userRepository;
  final FirebaseUserDataSource userDataSource;

  ProfileBloc({
    required this.getUserProfile,
    required this.userRepository,
    required this.userDataSource,
  }) : super(ProfileInitial()) {
    on<GetUserProfileEvent>(_onGetUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<UploadProfileImageFromUrlEvent>(_onUploadProfileImageFromUrl);
  }

  Future<void> _onGetUserProfile(
    GetUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getUserProfile(GetUserProfileParams(email: event.email));
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await userRepository.updateUserProfile(
      email: event.email,
      username: event.username,
      age: event.age,
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) async {
        emit(ProfileUpdated());
        add(GetUserProfileEvent(email: event.email));
      },
    );
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileImageUploading());
    try {
      final imageUrl = await userDataSource.uploadProfileImage(
        email: event.email,
        imageFile: event.imageFile,
      );
      emit(ProfileImageUploaded(imageUrl));
      add(GetUserProfileEvent(email: event.email));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUploadProfileImageFromUrl(
    UploadProfileImageFromUrlEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileImageUploading());
    try {
      final imageUrl = await userDataSource.uploadProfileImageFromUrl(
        email: event.email,
        imageUrl: event.imageUrl,
      );
      emit(ProfileImageUploaded(imageUrl));
      add(GetUserProfileEvent(email: event.email));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}