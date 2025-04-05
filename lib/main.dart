import 'dart:async';
import 'package:flutter/material.dart';
import 'package:brainboost/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brainboost/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brainboost/component/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    runApp(const MyApp());
  }, (Object error, StackTrace stackTrace) {
    print('runZonedGuarded: Caught error in my root zone. $error');
  });
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
