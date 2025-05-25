import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brainboost/services/user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:brainboost/services/history.dart';

class AuthController {
  final UserServices userServices = UserServices();
  final GameHistoryService historyService = GameHistoryService();

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
          // For new users, initialize both user and history collections
          await userServices.addUser(email: user.email!);
          await _initializeUserHistory(email: user.email!);
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
  
  // Helper method to initialize history collection
  Future<void> _initializeUserHistory({required String email}) async {
    try {
      // Initialize history document with empty data array
      await FirebaseFirestore.instance.collection('history').doc(email).set({
        'data': [],
        // 'created_at': FieldValue.serverTimestamp(),
      });
      print("History collection initialized for new Google user");
    } catch (e) {
      print('❌ Error initializing history collection: $e');
    }
  }
}
