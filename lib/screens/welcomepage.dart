import 'package:brainboost/screens/login.dart';
import 'package:brainboost/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    // วงกลมก้อนเมฆ
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
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff002366),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 250,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(double.infinity, 100),
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
              bottom: 0, // Make container extend to bottom
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                            color: Color(0xff002366),
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
                        color: Color(0xff002366),
                      ),
                    ),
                    Expanded(child: SizedBox()), // Push button to the bottom
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F6F9),
                        foregroundColor: Color(0xff002366),
                        elevation: 0,
                        minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await AuthService()
                              .signInWithGoogle(context: context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error signing in with Google: $e'),
                              action: SnackBarAction(
                                label: 'submit',
                                onPressed: () async {
                                  await AuthService().signup(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    context: context,
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      },

                      // },
                      child: const Text(
                        "Sign in with google",
                        style: TextStyle(
                          color: Color(0xff002366),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Add some padding at the bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
