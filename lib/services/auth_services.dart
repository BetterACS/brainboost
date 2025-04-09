import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brainboost/services/user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final UserServices userServices = UserServices();

  Future<void> signup(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));
      await userServices.addUser(email: email);

      context.push("/home");
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {}
  }

  Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 1));

      context.push("/home");
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {}
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    await context.push("/welcome");
  }

  // Future<UserCredential?> signInWithGoogle({required BuildContext context}) async {
  //   try {
  //     // Create a new provider
  //     final googleProvider = GoogleAuthProvider();
      
  //     // For mobile, desktop, and web
  //     UserCredential result;
  //     if (kIsWeb) {
  //       result = await FirebaseAuth.instance.signInWithPopup(googleProvider);
  //     } else {
  //       // First, trigger the authentication flow
  //       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //       if (googleUser == null) {
  //         return null;
  //       }
        
  //       // Obtain the auth details from the request
  //       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  //       // Create a new credential
  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );

  //       // Sign in to Firebase with the credential
  //       result = await FirebaseAuth.instance.signInWithCredential(credential);
  //     }
      
  //     if (result.user != null) {
  //       // Navigate to home page after successful sign-in
  //       context.go('/home');
  //     }
      
  //     return result;
  //   } catch (e) {
  //     print('Error during Google sign in: $e');
  //     rethrow;
  //   }
  // }

 Future<UserCredential?> signInWithGoogle({required BuildContext context}) async {
  try {
    final googleProvider = GoogleAuthProvider();
    UserCredential result;

    if (kIsWeb) {
      result = await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      result = await FirebaseAuth.instance.signInWithCredential(credential);
      print("Cached photoURL from GoogleSignIn: ${googleUser.photoUrl}");
    }

    final user = result.user;
    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.email);
      final doc = await docRef.get();

      if (!doc.exists) {
        await userServices.addUser(email: user.email!);
      } else {
        await docRef.update({'latest_login': FieldValue.serverTimestamp()});
      }

      context.go('/home');
    }

    return result;
  } catch (e) {
    print('❌ Error during Google sign-in: $e');
    return null;
  }
}

}
