import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/component/avatar.dart';

class ProfileContainer extends StatefulWidget {
  const ProfileContainer({super.key});

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  User? currentUser;
  bool isLoading = true;
  bool imageFailed = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      isLoading = true;
    });

    currentUser = FirebaseAuth.instance.currentUser;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (currentUser == null) {
      return const Text("User not found");
    }

    final username = currentUser!.displayName ?? 'Guest';
    final String? profileIcon = currentUser!.photoURL;

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 14, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.neutralBackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: profileIcon != null && !imageFailed
                ? UserAvatar(width: 32, imageUrl: profileIcon)
                : ClipOval(
                    child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover),
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
  }
}
