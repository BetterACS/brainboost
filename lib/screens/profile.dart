import 'package:flutter/material.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 80,
            child: Icon(Icons.person_outlined, size: 80),
          ),
          const SizedBox(height: 20),
          const Text(
            'User Name',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text("Profile"),


          /// Navigate to the settings page.
          /// [context.push] is a helper method from [GoRouter] that pushes a new route to the navigator.
          FilledButton(
            onPressed: () => context.push(Routes.settingsPage),
            child: const Text('Settings'),
          )
        ],
      ),
    ),
  );
}
