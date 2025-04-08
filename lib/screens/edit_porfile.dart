import 'package:brainboost/component/colors.dart';
import 'package:brainboost/services/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';

void main() {
  runApp(const EditProfilePage());
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor:
            isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor,
      ),
      home: const EditProfileScreen(),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController personalizeController = TextEditingController();

  Future<DocumentSnapshot> fetchUserData() async {
    final String? email = UserServices().getCurrentUserEmail();
    final DocumentSnapshot userDoc =
        await UserServices().users.doc(email).get();

    return userDoc;
  }

  Future<void> updateUserProfile() async {
    final String? email = UserServices().getCurrentUserEmail();

    final userDoc = await UserServices().users.doc(email).get();
    final currentUsername = userDoc['username'] ?? '';
    final currentEmail = userDoc['email'] ?? '';
    final currentPersonalize = userDoc.data().toString().contains('personalize')
        ? userDoc['personalize']
        : '';

    if (nameController.text == currentUsername &&
        emailController.text == currentEmail &&
        personalizeController.text == currentPersonalize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No changes made")),
      );
      return;
    }

    try {
      await UserServices().users.doc(email).update({
        'username': nameController.text,
        'email': emailController.text,
        'personalize': personalizeController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update Success")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
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
        child: FutureBuilder<DocumentSnapshot>(
          future: fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
            } else {
              final userDoc = snapshot.data!;
              final username = userDoc['username'] ?? 'ไม่มีชื่อผู้ใช้';
              final email = userDoc['email'] ?? 'ไม่มีอีเมล';
              final personalize =
                  userDoc.data().toString().contains('personalize')
                      ? userDoc['personalize']
                      : '';

              nameController.text = username;
              emailController.text = email;
              personalizeController.text = personalize;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField("Username", nameController),
                  const SizedBox(height: 20),
                  buildTextField("Email", emailController),
                  const SizedBox(height: 20),
                  buildTextField("Personalize", personalizeController),
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
                      onPressed: updateUserProfile,
                      child: const Text("Save",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: const Icon(Icons.edit, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
