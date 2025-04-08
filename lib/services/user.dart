import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brainboost/models/games.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class UserServices {
  final CollectionReference users =
      FirebaseFirestore.instance.collection("users");

  /// Adds a new user to the Firestore collection.
  Future<void> addUser({required String email}) async {
    final username = email.split('@')[0];

    // Convert DateTime objects to Timestamps for Firestore.
    final userData = {
      'email': email,
      'icon': 'default',
      'username': username,
      'create_at': Timestamp.now(),
      'latest_login': Timestamp.now(),
      'age': 12,
      'games': [],
      'recent_play': null
    };

    // Use the id (converted to a string) as the document ID.
    await users
        .doc(email)
        .set(userData)
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  /// Fetches a user's icon URL by email
  Future<String?> getUserIcon({required String email}) async {
    try {
      final userDoc = await users.doc(email.split("/").last).get();
      if (!userDoc.exists) {
        print("User not found for icon fetch");
        return null;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['icon'] as String?;

    } catch (error) {
      print("Failed to fetch user icon: $error");
      return null;
    }
  }

  String? getCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  Future<List<String>> getGames({
    required String email,
  }) async {
    try {
      final userDoc = await users.doc(email).get();
      if (!userDoc.exists) {
        print("User not found");
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData.containsKey('games')) {
        // Convert DocumentReference to string paths
        return (userData['games'] as List)
            .map((game) =>
                (game as DocumentReference).path) // Get path of each reference
            .toList();
      }

      return [];
    } catch (error) {
      print("Failed to get games: $error");
      return [];
    }
  }

  Future<String> getPersonalize({
    required String email,
  }) async {
    try {
      final userDoc = await users.doc(email).get();
      if (!userDoc.exists) {
        print("User not found");
        return "";
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      print(userData);
      // return as string.
      if (userData.containsKey('personalize')) {
        return userData['personalize'];
      }
      return "";

    } catch (error) {
      print("Failed to get games: $error");
      return "";
    }
  }
  
  Future<void> addSharedGame({required String email, required String gamePath}) async {
    try {
      // Get the current user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (userDoc.docs.isEmpty) {
        throw Exception('User not found');
      }
      
      final docId = userDoc.docs[0].id;
      
      // Get current games list
      List<dynamic> currentGames = userDoc.docs[0].data()['games'] ?? [];
      DocumentReference gameRef = FirebaseFirestore.instance.doc("/games/" + gamePath);

      // Check if game is already in user's collection
      if (currentGames.contains(gameRef)) {
        throw Exception('Game already in your collection');
      }
      
      // Add the new game path as a DocumentReference
      currentGames.add(gameRef);
      
      // Update the user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .update({'games': currentGames});
    } catch (e) {
      print('Error in addSharedGame: $e');
      throw e;
    }
  }

  // Updates the user's photo URL in Firestore
  Future<void> updateUserPhotoUrl(User user) async {
    if (user.email == null) return;
    String imageUrl = user.photoURL ?? '';
    if (imageUrl.isEmpty) return;


    try {
      // Download image from URL
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      
      // Create temp file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);

      // Create storage reference
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.email}_${DateTime.now().millisecondsSinceEpoch}');

      // Upload to Firebase Storage
      await storageRef.putFile(tempFile);
      final photoUrl = await storageRef.getDownloadURL();
      
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .update({
            'icon': photoUrl,
            'lastLogin': FieldValue.serverTimestamp(),
          });
      
      // Clean up temp file
      await tempFile.delete();
      
      print('Updated user photo URL in Firestore: $photoUrl');
    } catch (e) {
      print('Error updating user photo URL: $e');
      throw e;
    }
  }

  Future<void> updateUserProfile({
    required String email,
    String? username,
    int? age,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (username != null && username.isNotEmpty) {
        updateData['username'] = username;
      }
      
      if (age != null) {
        updateData['age'] = age;
      }
      
      if (updateData.isNotEmpty) {
        await users.doc(email).update(updateData);
      }
    } catch (e) {
      print("Error updating user profile: $e");
      throw e;
    }
  }

  Future<void> updateProfile({
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
        await users.doc(email).update(updateData);
        print("Profile updated successfully");
      }
    } catch (e) {
      print("Error updating profile: $e");
      throw e;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile({required String email}) async {
    try {
      final userDoc = await users.doc(email).get();
      if (!userDoc.exists) {
        print("User not found");
        return null;
      }

      return userDoc.data() as Map<String, dynamic>;
    } catch (error) {
      print("Failed to get user profile: $error");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error during sign out: $e");
      throw e;
    }
  }
}
