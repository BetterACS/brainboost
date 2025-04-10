import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileEvent extends ProfileEvent {
  final String email;

  const GetUserProfileEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class UpdateUserProfileEvent extends ProfileEvent {
  final String email;
  final String? username;
  final int? age;

  const UpdateUserProfileEvent({
    required this.email,
    this.username,
    this.age,
  });

  @override
  List<Object?> get props => [email, username, age];
}

class UploadProfileImageEvent extends ProfileEvent {
  final String email;
  final File imageFile;

  const UploadProfileImageEvent({
    required this.email,
    required this.imageFile,
  });

  @override
  List<Object> get props => [email, imageFile];
}

class UploadProfileImageFromUrlEvent extends ProfileEvent {
  final String email;
  final String imageUrl;

  const UploadProfileImageFromUrlEvent({
    required this.email,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [email, imageUrl];
}