import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: AppColors.buttonText),
        ),
        backgroundColor: AppColors.accentBackground,
        elevation: 0,
      ),
      backgroundColor: AppColors.accentBackground,
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 110),
            decoration: const BoxDecoration(
              color: Color(0xFF002D72),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
          ),
          Column(
            children: [
              _buildProfileHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8), 
                  children: [
                    _buildOptionsList(context),
                    const SizedBox(height: 20),
                    _buildLogOutButton(context),
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
  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Mon Chinawat",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Monchinawat@gmail.com",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Options List
  Widget _buildOptionsList(BuildContext context) {
    return Container(
      width: 380,
      height: 280,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOption(
            icon: Icons.edit,
            title: "Edit Profile",
            onTap: () => context.push(Routes.settingsPage),
          ),
          const SizedBox(height: 16),
          _buildOption(
            icon: Icons.settings,
            title: "Setting",
            onTap: () => context.push(Routes.settingsPage),
          ),
          const SizedBox(height: 16), 
          _buildOption(
            icon: Icons.palette,
            title: "Theme",
            trailing: const Text(
              "Light Open",
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
            onTap: () => context.push(Routes.settingsPage),
          ),
          const SizedBox(height: 16), 
          _buildOption(
            icon: Icons.support,
            title: "Support",
            onTap: () => context.push(Routes.settingsPage),
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
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8), 
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2B3A67), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold, 
                color: Color(0xFF2B3A67),
              ),
            ),
          ),
          if (trailing != null) trailing,
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios,
              size: 16, color: Color(0xFF9E9E9E)),
        ],
      ),
    ),
  );
}


  //Log Out Button
  Widget _buildLogOutButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.errorIcon,
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
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/alert.png',
                    height: 150,
                    width: 150,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Are you sure you want to log out?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
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
            );
          },
        );
      },
      child: const Text(
        "Log Out",
        style: TextStyle(fontSize: 16,
        fontWeight: FontWeight.bold, 
        ),
      ),
    );
  }
}
