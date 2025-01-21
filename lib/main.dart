import 'package:flutter/material.dart';
import 'package:brainboost/router/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// The [MaterialApp.router] widget is used to define the app's routes.
  /// See [router] in [router.dart] for the app's routes.
  /// See all the routes in [router/routes.dart].
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      );
}
