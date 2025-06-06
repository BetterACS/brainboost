import 'dart:async';
import 'package:brainboost/core/language/notifier.dart';
import 'package:brainboost/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brainboost/firebase_options.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brainboost/component/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final getIt = GetIt.instance;
void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    GetIt.instance
        .registerLazySingleton<LanguageNotifier>(() => LanguageNotifier());
    GetIt.instance.registerLazySingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance(),
    );
    await GetIt.instance.isReady<SharedPreferences>();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const MyApp());
  }, (error, stack) {
    print('runZonedGuarded: Caught error in my root zone. $error');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LanguageNotifier _languageNotifier;

  @override
  void initState() {
    super.initState();
    _languageNotifier = GetIt.instance<LanguageNotifier>();
    _languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
        ],
        child: MaterialApp.router(
          locale: _languageNotifier.locale,
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
          themeMode: ThemeMode.light,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ));
  }
}
