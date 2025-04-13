import 'package:brainboost/view/widgets/colors.dart';
import 'package:brainboost/core/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/view/widgets/history_item.dart';
import 'package:brainboost/view/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:brainboost/provider/theme_provider.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to prevent changing to the Coming Soon tab
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _tabController.animateTo(0);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getGameInfo(Map<String, dynamic> game) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('games')
          .doc(game['game_id'])
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print("Game document not found for ID: ${game['game_id']}");
        return {};
      }
    } catch (error) {
      print("Error fetching game info: $error");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.history,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            isDarkMode ? AppColors.accentDarkmode : AppColors.mainColor,
        foregroundColor: isDarkMode ? Colors.white : AppColors.buttonText,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: TabBar(
            controller: _tabController,
            labelColor: isDarkMode ? Colors.white : AppColors.buttonText,
            unselectedLabelColor:
                isDarkMode ? Colors.grey : AppColors.unselectedTab,
            indicatorColor: isDarkMode ? Colors.white : AppColors.buttonText,
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.games),
              Tab(text: AppLocalizations.of(context)!.tabcomingsoon),
            ],
            onTap: (index) {
              // If user taps on Coming Soon, keep them on Game tab
              if (index == 1) {
                _tabController.animateTo(0);
              }
            },
          ),
        ),
      ),
      backgroundColor:
          isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor,
      body: TabBarView(
        controller: _tabController,
        physics:
            NeverScrollableScrollPhysics(), // Prevents swiping between tabs
        children: [
          _buildHistoryTab(
              FirebaseAuth.instance.currentUser?.email, "game", isDarkMode),
          _buildComingSoonTab(), // Custom widget that will never be seen due to controller logic
        ],
      ),
    );
  }

  Widget _buildComingSoonTab() {
    return const Center(
      child: Text("Coming Soon..."),
    );
  }

  Widget _buildHistoryTab(String? email, String type, bool isDarkMode) {
    if (email == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 64,
              color: isDarkMode ? Colors.grey[300] : AppColors.buttonText,
            ),
            const SizedBox(height: 16),
            Text(
              "Please sign in to view your history",
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.grey[300] : AppColors.buttonText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (email.isEmpty) {
      return const Center(child: Text("No user email provided"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('history')
          .doc(email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading history"));
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.exists) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noHistoryFound),
          );
        }

        var docData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        List<Map<String, dynamic>> allGames =
            (docData['data'] as List<dynamic>?)
                    ?.whereType<Map<String, dynamic>>()
                    .toList() ??
                [];

        if (allGames.isEmpty) {
          return Center(
              child: Text(AppLocalizations.of(context)!.noHistoryFound));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: allGames.length,
          itemBuilder: (context, index) {
            var game = allGames[index];
            var timestamp = game['played_at'] as Timestamp?;
            var dateTime = timestamp?.toDate();
            var formattedDate = dateTime != null
                ? DateFormat('dd MMM yyyy').format(dateTime)
                : 'No date';

            return FutureBuilder<Map<String, dynamic>>(
              future: getGameInfo(game),
              builder: (context, gameInfoSnapshot) {
                // Use game info if available, otherwise fall back to history data
                String iconPath = "assets/${game['icon']}";
                var reference = game;

                if (gameInfoSnapshot.connectionState == ConnectionState.done &&
                    gameInfoSnapshot.hasData &&
                    gameInfoSnapshot.data!.isNotEmpty) {
                  // Use data from games collection if available
                  iconPath =
                      "assets/${gameInfoSnapshot.data!['icon'] ?? game['icon']}";

                  // Create a merged reference with both game history and game details
                  reference = {
                    ...game,
                    'gameDetails': gameInfoSnapshot.data,
                    'reference': 'games/${game['game_id']}'
                  };
                }

                return HistoryItem(
                  title: game['game_name'] ?? 'Unknown',
                  date: formattedDate,
                  imagePath: iconPath,
                  gameId: game['game_id'],
                  bestScore: game['best_score'] ?? 0,
                  // No need for onPressed or document reference - component handles it
                );
              },
            );
          },
        );
      },
    );
  }
}
