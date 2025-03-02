// lib/component/cards/profile.dart

import 'package:brainboost/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';

// Widget หลัก
class ProfileContainer extends StatefulWidget {
  const ProfileContainer({
    super.key,
  });

  @override
  State<ProfileContainer> createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  bool isProfileLoaded = false;

  Future<DocumentSnapshot> fetchUsername() async {
    final String? email = UserServices().getCurrentUserEmail();
    final DocumentSnapshot userDoc =
        await UserServices().users.doc(email).get();

    setState(() {
      isProfileLoaded = true;
    });
    return userDoc;
  }

  @override
  Widget build(BuildContext context) {
    // final String? email = UserServices().getCurrentUserEmail();
    // if (email == null) return const Text("User not logged in");

    return FutureBuilder<DocumentSnapshot>(
        future: fetchUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              isProfileLoaded == false) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text("User not found");
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final username = userData['username'] ?? 'Guest';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neutralBackground,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
