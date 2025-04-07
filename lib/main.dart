import 'dart:async';
import 'package:flutter/material.dart';
import 'package:brainboost/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brainboost/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brainboost/component/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up auth state listener to update user photo URL
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        updateUserPhotoUrl(user);
      }
    });

    final isDarkMode = await loadThemeFromFirestore();
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    runApp(const MyApp());
  }, (Object error, StackTrace stackTrace) {
    print('runZonedGuarded: Caught error in my root zone. $error');
  });
}

/// Updates the user's photo URL in Firestore
Future<void> updateUserPhotoUrl(User user) async {
  if (user.email == null) return;
  
  final photoUrl = user.photoURL;
  
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .update({
          'icon': photoUrl,
          'lastLogin': FieldValue.serverTimestamp(),
        });
    
    print('Updated user photo URL in Firestore: $photoUrl');
  } catch (e) {
    print('Error updating user photo URL: $e');
  }
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp.router(
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.primaryBackground,
            scaffoldBackgroundColor: AppColors.mainColor,
            textTheme: GoogleFonts.ibmPlexSansThaiTextTheme(
                Theme.of(context).textTheme),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.mainColor,
            scaffoldBackgroundColor: AppColors.mainColor, 
            textTheme: GoogleFonts.ibmPlexSansThaiTextTheme(
                Theme.of(context).textTheme),
          ),
          themeMode: currentTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.brightness_6),
      onPressed: () async {
        final isDarkMode = themeNotifier.value == ThemeMode.light;
        themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', isDarkMode);
      },
    );
  }
}

Future<bool> loadThemeFromFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .get();
    final theme = doc.data()?['Setting']['Theme'] ?? 'light';
    print('Theme loaded from Firestore: $theme');
    return theme == 'dark';
  }
  return false; // Default to light theme if user is not logged in
}
