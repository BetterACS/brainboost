import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/presentation/bloc/auth/auth_bloc.dart';
import 'package:brainboost/presentation/bloc/auth/auth_event.dart';
import 'package:brainboost/presentation/bloc/auth/auth_state.dart';

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 1.2), 114, paint);
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.95), 45, paint);
    canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.40), 70, yellowPaint);
    canvas.drawCircle(Offset(size.width * 0.57, size.height * 1.15), 77, paint);
    canvas.drawCircle(Offset(size.width * 0.79, size.height * 1.5), 83, paint);
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.97), 95, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // App logo or icon
              Icon(
                Icons.psychology,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              // App name
              Text(
                'BrainBoost',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              // App tagline
              Text(
                'Train your brain with fun games',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              // Login button
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              // Signup button
              OutlinedButton(
                onPressed: () => context.go('/signup'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
