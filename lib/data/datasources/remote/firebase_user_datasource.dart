import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:brainboost/core/errors/exceptions.dart';
import 'package:brainboost/data/models/user_model.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

abstract class FirebaseUserDataSource {
  /// Get user profile
  Future<UserModel> getUserProfile({required String email});

  /// Update user profile
  Future<void> updateUserProfile({
    required String email,
    String? username,
    String? profileImageUrl,
    int? age,
  });

  /// Add a new user
  Future<void> addUser({required String email});

  /// Get user games
  Future<List<String>> getUserGames({required String email});

  /// Add shared game to user
  Future<void> addSharedGame({
    required String email,
    required String gamePath,
  });

  /// Upload profile image
  Future<String> uploadProfileImage({
    required String email,
    required File imageFile,
  });

  /// Upload profile image from URL
  Future<String> uploadProfileImageFromUrl({
    required String email,
    required String imageUrl,
  });
}

class FirebaseUserDataSourceImpl implements FirebaseUserDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirebaseUserDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<UserModel> getUserProfile({required String email}) async {
    try {
      final userDoc = await firestore.collection('users').doc(email).get();
      
      if (!userDoc.exists) {
        throw ServerException('User not found');
      }
      
      return UserModel.fromFirestore(userDoc.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateUserProfile({
    required String email,
    String? username,
    String? profileImageUrl,
    int? age,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (username != null && username.isNotEmpty) {
        updateData['username'] = username;
      }
      
      if (profileImageUrl != null) {
        updateData['icon'] = profileImageUrl;
      }
      
      if (age != null) {
        updateData['age'] = age;
      }
      
      if (updateData.isNotEmpty) {
        await firestore.collection('users').doc(email).update(updateData);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addUser({required String email}) async {
    try {
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
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> getUserGames({required String email}) async {
    try {
      final userDoc = await firestore.collection('users').doc(email).get();
      
      if (!userDoc.exists) {
        throw ServerException('User not found');
      }
      
      final userData = userDoc.data()!;
      
      if (userData.containsKey('games')) {
        // Convert DocumentReference to string paths
        return (userData['games'] as List)
            .map((game) => 
                (game is DocumentReference) 
                    ? game.path 
                    : game.toString())
            .toList();
      }
      
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addSharedGame({
    required String email,
    required String gamePath,
  }) async {
    try {
      // Get the user document
      final userDoc = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) {
        throw ServerException('User not found');
      }
      
      final docId = userDoc.docs[0].id;
      
      // Get current games list
      List<dynamic> currentGames = userDoc.docs[0].data()['games'] ?? [];
      DocumentReference gameRef = firestore.doc(gamePath);

      // Check if game is already in user's collection
      if (currentGames.contains(gameRef)) {
        throw ServerException('Game already in your collection');
      }
      
      // Add the new game path as a DocumentReference
      currentGames.add(gameRef);
      
      // Update the user document
      await firestore
          .collection('users')
          .doc(docId)
          .update({'games': currentGames});
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadProfileImage({
    required String email,
    required File imageFile,
  }) async {
    try {
      // Create storage reference
      final storageRef = storage
          .ref()
          .child('profile_images')
          .child('${email}_${DateTime.now().millisecondsSinceEpoch}');

      // Upload to Firebase Storage
      await storageRef.putFile(imageFile);
      final photoUrl = await storageRef.getDownloadURL();
      
      // Update user profile
      await updateUserProfile(
        email: email,
        profileImageUrl: photoUrl,
      );
      
      return photoUrl;
    } catch (e) {
      throw ServerException('Failed to upload profile image: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImageFromUrl({
    required String email,
    required String imageUrl,
  }) async {
    try {
      // Download image from URL
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      
      // Create temp file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);

      // Upload the image
      final photoUrl = await uploadProfileImage(
        email: email,
        imageFile: tempFile,
      );
      
      // Clean up temp file
      await tempFile.delete();
      
      return photoUrl;
    } catch (e) {
      throw ServerException('Failed to upload profile image from URL: ${e.toString()}');
    }
  }
}