import 'package:brainboost/component/navbar.dart';
import 'package:flutter/material.dart';

class Game extends StatelessWidget {
  const Game({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile'),
      ),
      bottomNavigationBar: const Navbar(),
    );
  }
}
