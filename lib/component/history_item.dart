import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';

class HistoryItem extends StatelessWidget {
  final String title;
  final String date;
  final String imagePath;
  final int? bestScore;
  final DocumentReference? documentReference;
  final DocumentReference? gameId;
  final VoidCallback? onPressed;
  final Map<String, dynamic>? gameData;

  const HistoryItem({
    super.key,
    required this.title,
    required this.date,
    required this.imagePath,
    this.documentReference,
    this.gameId,
    this.onPressed,
    this.gameData,
    this.bestScore,
  }) : assert(documentReference != null || gameId != null, 
         'Either documentReference or gameId must be provided');

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.accentDarkmode : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6.0,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.buttonText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Best Score: ${bestScore ?? 0}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.blueGrey
                      : AppColors.neutralBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to handle play button press with data fetching
  void _handlePlayButtonPressed(BuildContext context) {
    // Determine which reference to use
    // final String gameIdToUse = gameId ?? 
    //     (documentReference != null ? documentReference!.id : '');

    // if (gameId.id) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Game reference not found')),
    //   );
    //   return;
    // }

    // Create the proper reference path
    // final String refPath = gameId;//documentReference?.path ?? 'games/$gameIdToUse';
    if (documentReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game reference not found')),
      );
      return;
    }

    // Show loading indicator
    final loadingOverlay = _showLoadingOverlay(context);

    // Fetch game data and navigate
    FirebaseFirestore.instance
        .doc(documentReference.toString())
        .get()
        .then((gameDoc) {
          // Hide loading indicator
          loadingOverlay?.remove();
          
          print(gameDoc);
          if (gameDoc.exists) {
            var gameData = gameDoc.data();
            if (gameData != null && gameData.containsKey('game_list')) {
              context.push(Routes.playGamePage, extra: {
                'games': gameData['game_list'],
                'reference': documentReference,
                'gameName': title,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Game data format is invalid')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Game data not found')),
            );
          }
        })
        .catchError((error) {
          // Hide loading indicator
          loadingOverlay?.remove();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading game: $error')),
          );
        });
  }

  // Helper method to show a loading overlay
  OverlayEntry? _showLoadingOverlay(BuildContext context) {
    final overlayState = Overlay.of(context);
    
    final overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading game...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlayState.insert(overlay);
    return overlay;
  }
}
