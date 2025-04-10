import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:brainboost/core/errors/exceptions.dart';
import 'package:brainboost/data/models/user_model.dart';
import 'package:flutter/foundation.dart';

abstract class FirebaseAuthDataSource {
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<UserModel> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserModel?> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get current user data
  Future<dynamic> getCurrentUser();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  FirebaseAuthDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException('User not found');
      }

      final userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.email)
          .get();

      if (!userDoc.exists) {
        throw AuthException('User document not found in Firestore');
      }

      // Update last login timestamp
      await firestore
          .collection('users')
          .doc(userCredential.user!.email)
          .update({'latest_login': FieldValue.serverTimestamp()});

      return UserModel.fromFirestore(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw AuthException('No user found for that email.');
      } else if (e.code == 'invalid-credential') {
        throw AuthException('Wrong password provided for that user.');
      }
      throw AuthException(e.message ?? 'Authentication error');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException('Failed to create user');
      }

      final username = email.split('@')[0];

      final userData = {
        'email': email,
        'icon': 'default',
        'username': username,
        'create_at': FieldValue.serverTimestamp(),
        'latest_login': FieldValue.serverTimestamp(),
        'age': 12,
        'games': [],
        'recent_play': null,
        'Setting': {
          'Theme': 'light',
          'Language': 'en',
        },
      };

      await firestore.collection('users').doc(email).set(userData);

      // Initialize history document with empty data array
      await firestore.collection('history').doc(email).set({
        'data': [],
      });

      // Fetch the newly created user data
      final userDoc = await firestore.collection('users').doc(email).get();
      return UserModel.fromFirestore(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('An account already exists with that email.');
      }
      throw AuthException(e.message ?? 'Authentication error');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null || user.email == null) {
        throw AuthException('Failed to get user data from Google sign in');
      }

      final docRef = firestore.collection('users').doc(user.email);
      final doc = await docRef.get();

      if (!doc.exists) {
        // For new users, initialize user and history
        final userData = {
          'email': user.email,
          'icon': user.photoURL ?? 'default',
          'username': user.displayName ?? user.email!.split('@')[0],
          'create_at': FieldValue.serverTimestamp(),
          'latest_login': FieldValue.serverTimestamp(),
          'age': 18,
          'games': [],
          'recent_play': null,
          'Setting': {
            'Theme': 'light',
            'Language': 'en',
          },
        };

        await docRef.set(userData);

        // Initialize history document with empty data array
        await firestore.collection('history').doc(user.email).set({
          'data': [],
        });

        // Fetch the newly created user
        final newUserDoc = await docRef.get();
        return UserModel.fromFirestore(newUserDoc.data()!);
      } else {
        // Update existing user's login timestamp
        await docRef.update({'latest_login': FieldValue.serverTimestamp()});
        return UserModel.fromFirestore(doc.data()!);
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        return null;
      }

      final userDoc =
          await firestore.collection('users').doc(currentUser.email).get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromFirestore(userDoc.data()!);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<dynamic> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final userData =
          await firestore.collection('users').doc(user.email).get();

      if (userData.exists) {
        return {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          ...userData.data() ?? {},
        };
      }

      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      };
    }
    return null;
  }
}
