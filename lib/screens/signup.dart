// import 'package:brainboost/screens/login.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/services/auth_services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/services/user.dart';


class Signup extends StatelessWidget {
  Signup({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserServices userServices = UserServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white, // Updated to use AppColors
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: _signin(context),
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground, // Updated to use AppColors
          elevation: 0,
          toolbarHeight: 50,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Register Account',
                    style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.8), // Updated to use AppColors
                            fontWeight: FontWeight.bold,
                            fontSize: 32)),
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                _emailAddress(),
                const SizedBox(
                  height: 20,
                ),
                _password(),
                const SizedBox(
                  height: 50,
                ),
                _signup(context),
              ],
            ),
          ),
        ));
  }

  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.raleway(
              textStyle: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.8), // Updated to use AppColors
                  fontWeight: FontWeight.normal,
                  fontSize: 16)),
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
              filled: true,
              hintText: 'mahdiforwork@gmail.com',
              hintStyle: TextStyle(
                  color: AppColors.gray5, // Updated to use AppColors
                  fontWeight: FontWeight.normal,
                  fontSize: 14),
              fillColor: AppColors.gray4, // Updated to use AppColors
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14))),
        )
      ],
    );
  }

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.raleway(
              textStyle: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.8), // Updated to use AppColors
                  fontWeight: FontWeight.normal,
                  fontSize: 16)),
        ),
        const SizedBox(
          height: 16,
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.gray4, // Updated to use AppColors
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14))),
        )
      ],
    );
  }

  Widget _signup(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.progressBlue, // Updated to use AppColors
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signup(
            email: _emailController.text,
            password: _passwordController.text,
            context: context);
      },
      child: Text(
        "Sign Up",
        style: TextStyle(
          color: AppColors.white, // Added text color with AppColors
        ),
      ),
    );
  }

  Widget _signin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
              text: "Already Have Account? ",
              style: TextStyle(
                  color: AppColors.gray5, // Updated to use AppColors
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
            TextSpan(
                text: "Log In",
                style: TextStyle(
                    color: AppColors.textPrimary, // Updated to use AppColors
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    context.push("/login");
                  }),
          ])),
    );
  }
}