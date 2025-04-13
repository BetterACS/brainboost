import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/core/routes/routes.dart';
import 'package:go_router/go_router.dart';

class LoadingHomeWrapper extends StatelessWidget {
  const LoadingHomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (snapshot.hasData) {
              context.go(Routes.homePage);
            } else {
              context.go('/welcome');
            }
          });

          return const SizedBox.shrink();
        });
  }
}
