// lib/component/cards/profile.dart
import 'package:brainboost/provider/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:brainboost/main.dart';
import 'package:brainboost/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/component/avatar.dart';
import 'package:brainboost/main.dart';
import 'package:provider/provider.dart';

class ProfileContainer extends StatefulWidget {
  const ProfileContainer({super.key});

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  User? currentUser;
  Widget? userAvatar;
  bool isLoading = true;
  String username = 'Loading...';

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
        userAvatar = UserAvatar(
          imageUrl: 'assets/images/profile.png',
          width: 32,
        );
        username = 'Guest';
      });
      return;
    }

    // Fetch username from Firestore
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .get();

    if (userDoc.exists) {
      username = userDoc['username'] ?? 'Guest';
    }

    String? path = await UserServices().getUserIcon(email: currentUser!.email!);
    if (path == null) {
      setState(() {
        isLoading = false;
        userAvatar = UserAvatar(
          imageUrl: 'assets/images/profile.png',
          width: 32,
        );
      });
      return;
    }

    try {
      final ref = storage.ref().child(path);
      final url = await ref.getDownloadURL();
      print(url);
      setState(() {
        userAvatar = UserAvatar(
          imageUrl: url,
          width: 32,
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        userAvatar = UserAvatar(
          imageUrl: 'assets/images/profile.png',
          width: 32,
        );
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return ValueListenableBuilder<ThemeMode>(
    //   valueListenable: themeNotifier,
    //   builder: (context, currentTheme, child) {
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    if (currentUser == null) {
      return const Text("User not found");
    }

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 14, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color:
            isDarkMode ? AppColors.accentDarkmode : AppColors.neutralBackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : userAvatar,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    // },
    // );
  }
}
