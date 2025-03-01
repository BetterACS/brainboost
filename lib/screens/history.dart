import 'package:brainboost/component/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/history_item.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            color: AppColors.buttonText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.buttonText,
            unselectedLabelColor: AppColors.unselectedTab,
            indicatorColor: AppColors.buttonText,
            indicatorWeight: 3.0,
            tabs: const [
              Tab(text: 'Game'),
              Tab(text: 'Coming Soon...'),
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
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // Prevents swiping between tabs
        children: [
          _buildHistoryTab(FirebaseAuth.instance.currentUser?.email, "game"),
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

  Widget _buildHistoryTab(String? email, String type) {
    if (email == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 64,
              color: AppColors.buttonText,
            ),
            const SizedBox(height: 16),
            const Text(
              "Please sign in to view your history",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.buttonText,
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
          return const Center(child: Text("No history found"));
        }

        var docData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        List<Map<String, dynamic>> allGames = docData.entries
            .where((entry) => entry.value is List)
            .expand((entry) =>
                (entry.value as List).whereType<Map<String, dynamic>>())
            .toList();

        allGames = allGames
            .where((game) => game["type"]?.toString() == type)
            .toList();

        if (allGames.isEmpty) {
          return const Center(child: Text("No history found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: allGames.length,
          itemBuilder: (context, index) {
            var game = allGames[index];
            return HistoryItem(
              title: game['game_name'] ?? 'Unknown',
              date: (game['play_at'] as Timestamp?)?.toDate().toString() ?? 'No date',
              imagePath: game['image_game'] ?? '',
              isDownload: game['isDownload'] ?? false,
              onPressed: () => print(game['game_name'] ?? 'Unknown'),
            );
          },
        );
      },
    );
  }
}