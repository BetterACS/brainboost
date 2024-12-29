import 'package:flutter/material.dart';
import 'package:brainboost/page/Mygames.dart';
import 'package:brainboost/page/Gamescreen.dart';
import 'package:brainboost/page/History.dart';
import 'package:brainboost/page/Profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrainBoost',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home', 
      routes: {
        '/home': (context) => const HomePage(),
        '/game': (context) => const Game(),
        '/history': (context) => const History(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}

