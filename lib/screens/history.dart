import 'package:brainboost/component/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/history_item.dart';
import 'package:brainboost/component/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
      backgroundColor: isDarkMode ? Colors.black : AppColors.mainColor,
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
            return HistoryItem(
              title: game['game_name'] ?? 'Unknown',
              date: (game['played_at'] as Timestamp?)?.toDate().toString() ??
                  'No date',
              imagePath: game['image_game'] ?? '',
              onPressed: () => print(game['game_name'] ?? 'Unknown'),
            );
          },
        );
      },
    );
  }
}
