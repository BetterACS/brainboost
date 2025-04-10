import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:brainboost/component/avatar.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/main.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/presentation/bloc/auth/auth_bloc.dart';
import 'package:brainboost/presentation/bloc/auth/auth_event.dart';
import 'package:brainboost/presentation/bloc/auth/auth_state.dart';
import 'package:brainboost/presentation/bloc/profile/profile_bloc.dart';
import 'package:brainboost/presentation/bloc/profile/profile_event.dart';
import 'package:brainboost/presentation/bloc/profile/profile_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      context.read<ProfileBloc>().add(
            GetUserProfileEvent(email: state.user.email),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.myProfile,
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppColors.buttonText,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: isDarkMode
                ? AppColors.backgroundDarkmode
                : AppColors.accentBackground,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
          ),
          backgroundColor: isDarkMode
              ? AppColors.backgroundDarkmode
              : AppColors.accentBackground,
          body: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 80),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.accentDarkmode
                      : const Color(0xFF002D72),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              ),
              Column(
                children: [
                  _buildProfileHeader(context, state, isDarkMode),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                      children: [
                        _buildOptionsList(context, isDarkMode),
                        const SizedBox(height: 20),
                        _buildLogOutButton(context, isDarkMode),
                      ],
                    ),
                  ),
                ],
              ),
              if (state is ProfileLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileState state, bool isDarkMode) {
    String username = 'Loading...';
    String email = 'Loading...';
    String? profileImageUrl;

    if (state is ProfileLoaded) {
      username = state.user.username;
      email = state.user.email;
      profileImageUrl = state.user.icon;
    } else if (state is ProfileError) {
      username = 'Error loading profile';
      email = '';
    }

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              if (state is ProfileLoading)
                const CircularProgressIndicator()
              else if (state is ProfileImageUploading)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    UserAvatar(
                      width: 120,
                      imageUrl: profileImageUrl ?? 'assets/images/profile.png',
                    ),
                    const CircularProgressIndicator(),
                  ],
                )
              else
                UserAvatar(
                  width: 120,
                  imageUrl: profileImageUrl ?? 'assets/images/profile.png',
                ),

              // Edit icon button
              GestureDetector(
                onTap: () => _pickAndUploadImage(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.accentDarkmode
                        : AppColors.primaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode
                          ? AppColors.backgroundDarkmode
                          : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final state = context.read<AuthBloc>().state;
    if (state is! Authenticated) return;

    try {
      Uint8List? fileBytes;
      String? fileName;

      if (kIsWeb) {
        // Web platform: use FilePicker
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
        );

        if (result == null || result.files.isEmpty) {
          return;
        }

        fileBytes = result.files.first.bytes;
        fileName = result.files.first.name;

        if (fileBytes == null) {
          return;
        }
      } else {
        // Mobile platform: use ImagePicker
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image == null) {
          return;
        }

        fileBytes = await image.readAsBytes();
        fileName = image.name;
        
        final file = File(image.path);
        
        // Upload profile image
        context.read<ProfileBloc>().add(
              UploadProfileImageEvent(
                email: state.user.email,
                imageFile: file,
              ),
            );
        
        return;
      }

      // For web platform (not implemented in this example)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Web image upload not implemented yet')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Widget _buildOptionsList(BuildContext context, bool isDarkMode) {
    return Container(
      width: 380,
      height: 220,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.accentDarkmode : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildOption(
            icon: Icons.edit,
            isDarkMode: isDarkMode,
            title: AppLocalizations.of(context)!.editProfile,
            onTap: () {
              context.push('/edit-profile');
            },
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon: Icons.settings,
            title: AppLocalizations.of(context)!.setting,
            onTap: () => context.push(Routes.settingsPage),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon: Icons.palette,
            title: AppLocalizations.of(context)!.theme,
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentTheme, child) {
                return Text(
                  currentTheme == ThemeMode.light
                      ? AppLocalizations.of(context)!.lightOpen
                      : AppLocalizations.of(context)!.darkOpen,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                );
              },
            ),
            onTap: () => _toggleTheme(context),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTheme(BuildContext context) async {
    final isCurrentlyLight = themeNotifier.value == ThemeMode.light;
    themeNotifier.value = isCurrentlyLight ? ThemeMode.dark : ThemeMode.light;

    final state = context.read<AuthBloc>().state;
    if (state is Authenticated) {
      final email = state.user.email;
      // This would be handled by the profile bloc in a real implementation
      // Here we're using the legacy implementation for simplicity
      try {
        context.read<ProfileBloc>().add(
              UpdateUserProfileEvent(
                email: email,
                username: null,
                // We would add a theme parameter to this event in a full implementation
              ),
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save theme: $e')),
        );
      }
    }
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDarkMode ? Colors.white : const Color(0xFF2B3A67),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.white70 : const Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutButton(BuildContext context, bool isDarkMode) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: state is AuthLoading
              ? null
              : () {
                  _showLogoutConfirmationDialog(context);
                },
          child: state is AuthLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  AppLocalizations.of(context)!.logOut,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: 350,
            height: 360,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/alert.png',
                  height: 200,
                  width: 180,
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.areYouSureLogout,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Logout button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<AuthBloc>().add(SignOutEvent());
                          context.go('/welcome');
                        },
                        child: Text(
                          AppLocalizations.of(context)!.logOut,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}