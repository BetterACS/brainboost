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
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff002366),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 250,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: _CloudPainter(),
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 200,
                ),
              ),
              Positioned(
                top: 370,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.raleway(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff002366),
                            ),
                            children: [
                              const TextSpan(text: "Let's "),
                              WidgetSpan(
                                child: Transform.rotate(
                                  angle: -5 * 3.14159 / 180,
                                  child: Container(
                                    color: Colors.amber,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 6.0),
                                    child: const Text(
                                      "boost",
                                      style: TextStyle(
                                        color: Color(0xFFF5F8FC),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: " your\nbrain to the sky"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Play to learn application make you\nmemorize class lecture more efficiently",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xff002366),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      _buildGoogleSignInButton(context),
                      const SizedBox(height: 20),
                      _buildNavigationButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF2F6F9),
            foregroundColor: const Color(0xff002366),
            elevation: 0,
            minimumSize: const Size(300, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: state is AuthLoading
              ? null
              : () {
                  context.read<AuthBloc>().add(SignInWithGoogleEvent());
                },
          child: state is AuthLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xff002366),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google_logo.png', 
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Sign in with Google",
                      style: TextStyle(
                        color: Color(0xff002366),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.push('/login'),
          child: const Text(
            'Login',
            style: TextStyle(
              color: Color(0xff002366),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 24),
        TextButton(
          onPressed: () => context.push('/signup'),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xff002366),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}