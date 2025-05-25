import 'dart:async';
import 'dart:ui';
// import 'package:brainboost/services/user.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brainboost/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brainboost/views/widgets/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:brainboost/controllers/home_controller.dart';
import 'package:brainboost/controllers/auth_controller.dart';
import 'package:brainboost/controllers/settings_controller.dart';

/// Used to scale smaller devices.
/// Font and sizes. Not used everywhere. Used for tweaking smaller device.

// Theme controller
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
// Locale controller // Will be removed
// final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en')); // Will be removed

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final isDarkMode = await loadThemeFromFirestore();
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // Load saved language
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('languageCode') ?? 'en';
    // localeNotifier.value = Locale(langCode); // Will be handled by SettingsController initial state or a load method later

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => HomeController()),
          ChangeNotifierProvider(create: (_) => SettingsController()),
        ],
        child: const MyApp(),
      ),
    );
  }, (Object error, StackTrace stackTrace) {
    print('runZonedGuarded: Caught error in my root zone. $error');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        // Set system UI overlay style based on theme
        SystemChrome.setSystemUIOverlayStyle(
          currentTheme == ThemeMode.light
              ? SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                )
              : SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                ),
        );
        
        final settingsController = Provider.of<SettingsController>(context); // Access SettingsController

        // return ValueListenableBuilder<Locale>( // Replace with Consumer or direct access
        //   valueListenable: localeNotifier,
        //   builder: (context, currentLocale, _) {
            return MaterialApp.router(
              locale: settingsController.locale, // Use locale from controller
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('th'),
                Locale('en'),
              ],
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: AppColors.primaryBackground,
                scaffoldBackgroundColor: AppColors.mainColor,
                textTheme: GoogleFonts.ibmPlexSansThaiTextTheme(
                  Theme.of(context).textTheme,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: AppColors.mainColor,
                scaffoldBackgroundColor: AppColors.mainColor,
                textTheme: GoogleFonts.ibmPlexSansThaiTextTheme(
                  Theme.of(context).textTheme,
                ),
              ),
              themeMode: currentTheme,
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}

// Button toggle theme
class ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.brightness_6),
      onPressed: () async {
        final isDarkMode = themeNotifier.value == ThemeMode.light;
        themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', isDarkMode);
      },
    );
  }
}

// Load theme from Firestore
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
  return false;
}

// Function to switch language
Future<void> switchLanguage(BuildContext context, String languageCode) async {
  // Get the SettingsController from the context
  final settingsController = Provider.of<SettingsController>(context, listen: false);
  settingsController.setLocale(Locale(languageCode));
  
  // SharedPreferences logic can remain here for now, or be moved into controller later
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('languageCode', languageCode);
}

// Remove the old localeNotifier global variable:
// final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));
