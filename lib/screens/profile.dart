import 'package:brainboost/component/colors.dart';
import 'package:brainboost/main.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
                title: Text(
          'My Profile',
          style: TextStyle(
            color: isDarkMode
              ? Colors.white 
              : AppColors.buttonText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode
            ? AppColors.backgroundDarkmode 
            : AppColors.accentBackground,
        iconTheme: IconThemeData(
          color:  Colors.white 
           
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
              _buildProfileHeader(isDarkMode),
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
                backgroundColor:  AppColors.buttonText, 
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
          Text(
            "Mon Chinawat",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Monchinawat@gmail.com",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white
            ),
          ),
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
        color: isDarkMode
            ? AppColors.accentDarkmode 
            : Colors.white,
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
            title: "Edit Profile",
            onTap: () => context.push(Routes.settingsPage),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon: Icons.settings,
            title: "Setting",
            onTap: () => context.push(Routes.settingsPage),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon: Icons.palette,
            title: "Theme",
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentTheme, child) {
                return Text(
                  currentTheme == ThemeMode.light ? "Light Open" : "Dark Open",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white 
                        : Colors.black, 
                    fontSize: 14,
                  ),
                );
              },
            ),
            onTap: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          _buildOption(
            icon: Icons.support,
            title: "Support",
            onTap: () => context.push(Routes.settingsPage),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  // Individual Option
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
              color: isDarkMode
                  ? Colors.white
                  : const Color(0xFF2B3A67), 
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.white 
                      : Colors.black, 
                ),
              ),
            ),
            if (trailing != null) trailing,
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode
                  ? Colors.white70 
                  : const Color(0xFF9E9E9E), 
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
                    const Text(
                      "Are you sure you want to log out?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.errorIcon,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Logged Out Successfully!"),
                                ),
                              );
                            },
                            child: const Text(
                              "Log Out",
                              style: TextStyle(color: Colors.white),
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
      child: const Text(
        "Log Out",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
