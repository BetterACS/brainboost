import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:brainboost/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brainboost/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brainboost/component/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';

// Core
import 'package:brainboost/core/network/dio_client.dart';

// Data sources
import 'package:brainboost/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:brainboost/data/datasources/remote/firebase_user_datasource.dart';
import 'package:brainboost/data/datasources/remote/firebase_game_datasource.dart';

// Repositories
import 'package:brainboost/data/repositories/auth_repository_impl.dart';
import 'package:brainboost/data/repositories/user_repository_impl.dart';
import 'package:brainboost/data/repositories/game_repository_impl.dart';
import 'package:brainboost/domain/repositories/auth_repository.dart';
import 'package:brainboost/domain/repositories/user_repository.dart';
import 'package:brainboost/domain/repositories/game_repository.dart';

// Use cases
import 'package:brainboost/domain/usecases/auth/sign_in_with_email_password.dart';
import 'package:brainboost/domain/usecases/auth/sign_up_with_email_password.dart';
import 'package:brainboost/domain/usecases/auth/sign_in_with_google.dart';
import 'package:brainboost/domain/usecases/auth/sign_out.dart';
import 'package:brainboost/domain/usecases/user/get_user_profile.dart';
import 'package:brainboost/domain/usecases/game/get_all_games.dart';
import 'package:brainboost/domain/usecases/game/get_user_games.dart';

// BLoCs
import 'package:brainboost/presentation/bloc/auth/auth_bloc.dart';
import 'package:brainboost/presentation/bloc/profile/profile_bloc.dart';
import 'package:brainboost/presentation/bloc/games/games_bloc.dart';
import 'package:brainboost/presentation/bloc/home/home_bloc.dart';

final GetIt getIt = GetIt.instance;

// Theme controller
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
// Locale controller
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await setupDependencies();

    final isDarkMode = await loadThemeFromFirestore();
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // Load saved language
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('languageCode') ?? 'en';
    localeNotifier.value = Locale(langCode);

    runApp(const MyApp());
  }, (Object error, StackTrace stackTrace) {
    print('runZonedGuarded: Caught error in my root zone. $error');
  });
}

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton(() => DioClient(baseUrl: 'https://api.example.com'));

  // Firebase
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);
  getIt.registerLazySingleton(() => GoogleSignIn());
  getIt.registerLazySingleton(() => Dio());

  // Data sources
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(
      firebaseAuth: getIt(),
      firestore: getIt(),
      googleSignIn: getIt(),
    ),
  );
  getIt.registerLazySingleton<FirebaseUserDataSource>(
    () => FirebaseUserDataSourceImpl(
      firestore: getIt(),
      storage: getIt(),
    ),
  );
  getIt.registerLazySingleton<FirebaseGameDataSource>(
    () => FirebaseGameDataSourceImpl(
      firestore: getIt(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      dataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(
      dataSource: getIt(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => SignInWithEmailPassword(getIt()));
  getIt.registerLazySingleton(() => SignUpWithEmailPassword(getIt()));
  getIt.registerLazySingleton(() => SignInWithGoogle(getIt()));
  getIt.registerLazySingleton(() => SignOut(getIt()));
  getIt.registerLazySingleton(() => GetUserProfile(getIt()));
  getIt.registerLazySingleton(() => GetAllGames(getIt()));
  getIt.registerLazySingleton(() => GetUserGames(getIt()));

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      signInWithEmailPassword: getIt(),
      signUpWithEmailPassword: getIt(),
      signInWithGoogle: getIt(),
      signOut: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerFactory(
    () => ProfileBloc(
      getUserProfile: getIt(),
      userRepository: getIt(),
      userDataSource: getIt(),
    ),
  );
  getIt.registerFactory(
    () => GamesBloc(
      getAllGames: getIt(),
      getUserGames: getIt(),
      gameRepository: getIt(),
      userRepository: getIt(),
      firestore: getIt(),
      storage: getIt(),
    ),
  );
  getIt.registerFactory(
    () => HomeBloc(
      userRepository: getIt(),
      gameRepository: getIt(),
      userDataSource: getIt(),
      firestore: getIt(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>(),
        ),
        BlocProvider<GamesBloc>(
          create: (_) => getIt<GamesBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => getIt<HomeBloc>(),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
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

          return ValueListenableBuilder<Locale>(
            valueListenable: localeNotifier,
            builder: (context, currentLocale, _) {
              return MaterialApp.router(
                locale: currentLocale,
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
      ),
    );
  }
}

// Button toggle theme
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

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
Future<void> switchLanguage(String languageCode) async {
  localeNotifier.value = Locale(languageCode);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('languageCode', languageCode);
}