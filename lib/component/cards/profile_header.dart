// lib/component/cards/profile.dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:brainboost/main.dart';
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, 
      builder: (context, currentTheme, child) {
        final isDarkMode = currentTheme == ThemeMode.dark;

        return FutureBuilder<DocumentSnapshot>(
          future: fetchUsername(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                isProfileLoaded == false) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(AppLocalizations.of(context)!.noUserFound);
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['username'] ?? 'Guest';

            return Container(
              padding: const EdgeInsets.only(left: 10, right: 14, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.accentDarkmode 
                    : AppColors.neutralBackground, 
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                  ),
                  const SizedBox(width: 8),
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
          },
        );
      },
    );
  }
}
