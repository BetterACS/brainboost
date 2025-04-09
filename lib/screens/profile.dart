import 'package:brainboost/component/avatar.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/screens/welcomepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brainboost/main.dart';
import 'package:brainboost/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/screens/edit_porfile.dart';
import 'package:brainboost/screens/support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/services/user.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/services/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'Loading...';
  String email = 'Loading...';
  bool isProfileLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    String? email = UserServices().getCurrentUserEmail();
    final DocumentSnapshot userDoc =
        await UserServices().users.doc(email).get();

    if (userDoc.exists) {
      setState(() {
        username = userDoc['username'] ?? 'No username';
        this.email = userDoc['email'] ?? 'No email';
        isProfileLoaded = true;
      });
    } else {
      setState(() {
        username = 'No data';
        email = 'No data';
        isProfileLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
        iconTheme: IconThemeData(
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
              ProfileHeaderWidget(
                username: username,
                email: email,
              ),
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
        ],
      ),
    );
  }

  // Profile Header
  Widget _buildProfileHeader(bool isDarkMode) {
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
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile.jpg'),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.buttonText,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          isProfileLoaded
              ? Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : const CircularProgressIndicator(),
          const SizedBox(height: 4),
          isProfileLoaded
              ? Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                )
              : const CircularProgressIndicator(),
        ],
      ),
    );
  }

  // Options List
  Widget _buildOptionsList(BuildContext context, bool isDarkMode) {
    return Container(
      width: 380,
      height: 300,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
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
            onTap: () async {
              final isCurrentlyLight = themeNotifier.value == ThemeMode.light;
              themeNotifier.value =
                  isCurrentlyLight ? ThemeMode.dark : ThemeMode.light;

              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.email)
                    .update({
                  'Setting.Theme': isCurrentlyLight ? 'dark' : 'light',
                });
                print(
                    'Theme saved to Firestore: ${isCurrentlyLight ? "dark" : "light"}');
              }
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon: Icons.support,
            title: AppLocalizations.of(context)!.support,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SupportPage()),
              );
            },
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
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

  // Log Out Button
  Widget _buildLogOutButton(BuildContext context, bool isDarkMode) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
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
                        // ปุ่ม Cancel
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side:
                                  const BorderSide(color: Colors.red, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // ปุ่ม Logout
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .red, // ใช้ Colors.red แทน AppColors.errorIcon
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await AuthService().signout(context: context);

                                if (context.mounted) {
                                  Navigator.of(context)
                                      .pop(); // ปิด AlertDialog ก่อน
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .loggedOutSuccess,
                                      ),
                                    ),
                                  );
                                }

                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => WelcomePage(),
                                    ),
                                    (route) => false, // เคลียร์ทุกหน้าใน Stack
                                  );
                                }
                              } catch (e) {
                                print("Error logging out: $e");
                              }
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
      },
      child: Text(
        AppLocalizations.of(context)!.logOut,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ProfileHeaderWidget extends StatefulWidget {
  final String username;
  final String email;

  const ProfileHeaderWidget({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  User? currentUser;
  String? profileImageUrl;
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    FirebaseStorage storage = FirebaseStorage.instance;

    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    String? path = await UserServices().getUserIcon(email: currentUser!.email!);
    if (path == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      if (path.startsWith('profile_images/')) {
        // Path is already a storage path
        final ref = storage.ref().child(path);
        final url = await ref.getDownloadURL();
        setState(() {
          profileImageUrl = url;
          isLoading = false;
        });
      } else if (path.startsWith('http')) {
        // Path is already a URL
        setState(() {
          profileImageUrl = path;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _changeProfileImage() async {
    if (currentUser == null || isUploading) return;

    setState(() {
      isUploading = true;
    });

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
          setState(() {
            isUploading = false;
          });
          return;
        }

        fileBytes = result.files.first.bytes;
        fileName = result.files.first.name;

        if (fileBytes == null) {
          setState(() {
            isUploading = false;
          });
          return;
        }
      } else {
        // Mobile platform: use ImagePicker
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image == null) {
          setState(() {
            isUploading = false;
          });
          return;
        }

        fileBytes = await image.readAsBytes();
        fileName = image.name;
      }

      // Create storage reference
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(
              '${currentUser!.email}_${DateTime.now().millisecondsSinceEpoch}_$fileName');

      // Upload to Firebase Storage
      if (kIsWeb) {
        await storageRef.putData(fileBytes!);
      } else {
        await storageRef.putData(fileBytes);
      }

      final newPhotoUrl = await storageRef.getDownloadURL();
      final storagePath = storageRef.fullPath;

      // Update Firestore through our service
      await UserServices().updateProfile(
        username: currentUser?.displayName ?? '',
        email: currentUser?.email ?? '',
        profileImageUrl: storagePath,
      );

      // Update UI
      setState(() {
        profileImageUrl = newPhotoUrl;
        isUploading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: $e')),
        );
      }
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              if (isLoading)
                const CircularProgressIndicator()
              else if (isUploading)
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
                onTap: _changeProfileImage,
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
                  child: Icon(
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
            widget.username,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
