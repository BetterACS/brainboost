import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/presentation/bloc/profile/profile_bloc.dart';
import 'package:brainboost/presentation/bloc/profile/profile_event.dart';
import 'package:brainboost/presentation/bloc/profile/profile_state.dart';
import 'package:brainboost/presentation/bloc/auth/auth_bloc.dart';
import 'package:brainboost/presentation/bloc/auth/auth_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController personalizeController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    nameController.dispose();
    personalizeController.dispose();
    super.dispose();
  }

  void _initializeControllers(ProfileState state) {
    if (state is ProfileLoaded && !_initialized) {
      nameController.text = state.user.username;
      // We would need to add a personalize field to the UserEntity
      // personalizeController.text = state.user.personalize ?? '';
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.message}")),
          );
        }
        
        _initializeControllers(state);
      },
      child: Scaffold(
        backgroundColor:
            isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            backgroundColor:
                isDarkMode ? AppColors.accentDarkmode : AppColors.buttonText,
            leading: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: const Color(0xFF092866),
                height: 1,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is ProfileLoaded || state is ProfileUpdated) {
                _initializeControllers(state);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextField("Username", nameController),
                    const SizedBox(height: 20),
                    buildTextField("Personalize", personalizeController, maxLines: 4),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? AppColors.accentDarkmode2
                              : AppColors.buttonText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _updateProfile,
                        child: const Text(
                          "Save",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Initial state
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  // If we have the authentication state but not the profile state yet,
                  // trigger the profile loading
                  context.read<ProfileBloc>().add(
                        GetUserProfileEvent(email: authState.user.email),
                      );
                }
                
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  void _updateProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username cannot be empty")),
        );
        return;
      }

      context.read<ProfileBloc>().add(
            UpdateUserProfileEvent(
              email: authState.user.email,
              username: nameController.text,
              // Add handling for personalize data when available in the entity
            ),
          );
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, int? maxLines}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.buttonText,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: Icon(
              Icons.edit,
              color: isDarkMode ? AppColors.backgroundDarkmode : AppColors.buttonText,
            ),
          ),
        ),
      ],
    );
  }
}