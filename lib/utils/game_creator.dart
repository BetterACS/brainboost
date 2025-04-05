import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:brainboost/services/games.dart';
import 'package:brainboost/services/user.dart';
import 'package:brainboost/services/history.dart';
import 'package:brainboost/component/dialogs/error_dialog.dart';
import 'package:brainboost/component/dialogs/success_dialog.dart';
// import 'package:brainboost/component/dialogs/creating_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CreationStage { extracting, personalizing, crafting, completed }

Future<void> createGameFunction(
  BuildContext context, {
  required String uploadLink,
  required String gameName,
  required ValueNotifier<String> dialogMessage,
  required ValueNotifier<double> creationProgress,
  required ValueNotifier<CreationStage> currentStage,
  VoidCallback? onSuccess,
}) async {
  if (uploadLink.isEmpty || gameName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please upload a file and enter a game name')),
    );
    return;
  }

  dialogMessage.value = "";
  creationProgress.value = 0.0;
  currentStage.value = CreationStage.extracting;

  // Store the dialog context to safely close it later
  BuildContext? dialogContext;
  
  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (context) {
  //     dialogContext = context;
  //     return CreatingDialog(
  //       dialogMessage: dialogMessage,
  //       creationProgress: creationProgress,
  //       currentStage: currentStage,
  //     );
  //   },
  // );

  try {
    var httpClient = http.Client();
    dialogMessage.value = "Extract valuable information from the file";
    creationProgress.value = 0.25;

    var extractResponse = await httpClient
        .get(Uri.https('monsh.xyz', '/extract', {'pdf_path': uploadLink}));

    currentStage.value = CreationStage.personalizing;
    dialogMessage.value = "Get your personalize";
    creationProgress.value = 0.32;

    String? email = FirebaseAuth.instance.currentUser!.email;
    if (email == null) {
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(),
      );
      return;
    }

    String personalize = await UserServices().getPersonalize(email: email);

    var decodedResponse = utf8.decode(extractResponse.bodyBytes);
    Map<String, dynamic> jsonDict = jsonDecode(decodedResponse);

    currentStage.value = CreationStage.crafting;
    dialogMessage.value = "Crafting your game";
    Map<String, String> params = {
      "game_type": 'quiz',
      "context": jsonDict['data'],
      "personalize": personalize,
      "language": "Thai and English upon to context.",
      "num_games": "3",
    };

    var createGameResponse = await httpClient.post(
      Uri.https('monsh.xyz', '/create_game'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(params),
    );

    creationProgress.value = 0.80;

    var gameDict = jsonDecode(utf8.decode(createGameResponse.bodyBytes));

    GameServices gamesServices = GameServices();

    final DocumentReference<Object?>? gameID = await gamesServices.createGame(
        name: gameName,
        email: FirebaseAuth.instance.currentUser!.email!,
        gameData: gameDict['data'] as List<dynamic>,
        media: uploadLink);

    if (gameID == null) {
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(),
      );
      return;
    }

    await gamesServices.addGameToUser(
        email: FirebaseAuth.instance.currentUser!.email!, docPath: gameID);

    GameHistoryService gameHistoryService = GameHistoryService();
    await gameHistoryService.addGameHistory(
        email: email, gameId: gameID, gameName: gameName);

    currentStage.value = CreationStage.completed;
    creationProgress.value = 1.0;
    dialogMessage.value = "Game creation completed!";

    // Wait a moment to show the completed state before closing
    await Future.delayed(Duration(seconds: 1));

    // Close the dialog safely
    if (dialogContext != null && Navigator.canPop(dialogContext!)) {
      Navigator.pop(dialogContext!);
    }

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => const SuccessDialog(),
    );

    // Call onSuccess callback if provided
    if (onSuccess != null) {
      onSuccess();
    }
  } catch (e) {
    print("Error during game creation: $e");
    
    // Make sure to close the dialog if there's an error
    if (dialogContext != null && Navigator.canPop(dialogContext!)) {
      Navigator.pop(dialogContext!);
    }
    
    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(),
    );
  }
}
