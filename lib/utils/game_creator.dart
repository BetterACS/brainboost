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
ValueNotifier<String> dialogMessage = ValueNotifier<String>("");
ValueNotifier<double> creationProgress = ValueNotifier<double>(0.0);
ValueNotifier<CreationStage> currentStage =
    ValueNotifier<CreationStage>(CreationStage.extracting);

Future<void> createGameFunction(
  BuildContext context, {
  required String uploadLink,
  required String gameName,
  // required ValueNotifier<String> dialogMessage,
  // required ValueNotifier<double> creationProgress,
  // required ValueNotifier<CreationStage> currentStage,
  VoidCallback? onSuccess,
  bool showInternalDialogs = true, // Add parameter to control internal dialog behavior
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
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      dialogContext = context; // Capture the dialog context
      return const CreatingDialog();
    },
  );

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
      if (dialogContext != null && Navigator.canPop(dialogContext!) && showInternalDialogs) {
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
      if (dialogContext != null && Navigator.canPop(dialogContext!) && showInternalDialogs) {
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

    // Close the dialog safely, only if we're showing internal dialogs
    if (dialogContext != null && Navigator.canPop(dialogContext!) && showInternalDialogs) {
      Navigator.pop(dialogContext!);
    }

    // Show success dialog only if we're using internal dialogs
    if (showInternalDialogs) {
      showDialog(
        context: context,
        builder: (context) => const SuccessDialog(),
      );
    }

    // Call onSuccess callback if provided
    if (onSuccess != null) {
      onSuccess();
    }
  } catch (e) {
    print("Error during game creation: $e");
    
    // Make sure to close the dialog if there's an error, only if using internal dialogs
    if (dialogContext != null && Navigator.canPop(dialogContext!) && showInternalDialogs) {
      Navigator.pop(dialogContext!);
    }
    
    // Show error dialog only if using internal dialogs
    if (showInternalDialogs) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(),
      );
    } else {
      // If not using internal dialogs, just rethrow to let the caller handle it
      throw e;
    }
  }
}


// Pop-up creating
class CreatingDialog extends StatefulWidget {
  const CreatingDialog({super.key});

  @override
  _CreatingDialogState createState() => _CreatingDialogState();
}

class _CreatingDialogState extends State<CreatingDialog> {
  @override
  void initState() {
    super.initState();
    dialogMessage.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild dialog when message changes
      }
    });
    creationProgress.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    dialogMessage.removeListener(() {}); // Avoid memory leaks
    creationProgress.removeListener(() {});
    super.dispose();
  }

  double getProgressForStage(CreationStage stage) {
    switch (stage) {
      case CreationStage.extracting:
        return 0.33;
      case CreationStage.personalizing:
        return 0.66;
      case CreationStage.crafting:
        return 0.99;
      case CreationStage.completed:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: -15,
                      child: Container(
                        width: 200,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E9E9),
                          borderRadius: BorderRadius.circular(80),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/file.png',
                        width: 200,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Text(
                  dialogMessage.value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFE9E9E9),
                    color: Colors.blue.shade800,
                    minHeight: 10,
                    value: creationProgress.value,
                  ),
                )
              ],
            ),
          ),
          // Positioned(
          //   top: 5,
          //   right: 5,
          //   child: IconButton(
          //     icon: const Icon(Icons.close, color: Color(0xFF838383)),
          //     onPressed: () {
          //       Navigator.pop(context);
          //       Navigator.pushReplacement(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => const UploadFileScreen()),
          //       );
          //     },
          //     tooltip: 'Close',
          //   ),
          // ),
        ],
      ),
    );
  }
}
