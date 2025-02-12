import 'package:brainboost/component/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  final String email;
  const History({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'History',
            style: TextStyle(
              color: AppColors.buttonText,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: TabBar(
              labelColor: AppColors.buttonText,
              unselectedLabelColor: AppColors.unselectedTab,
              indicatorColor: AppColors.buttonText,
              indicatorWeight: 3.0,
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Game'),
                Tab(text: 'Summarize'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildHistoryTab(email, "all"),
            _buildHistoryTab(email, "game"),
            _buildHistoryTab(email, "summarize"),
          ],
        ),
      ),
    );
  }
Widget _buildHistoryTab(String email, String type) {
  if (email.isEmpty) {
    return const Center(child: Text("No user email provided"));
  }

  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance.collection('history').doc(email).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return const Center(child: Text("Error loading history"));
      }

      if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
        return const Center(child: Text("No history found"));
      }

      var docData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

      List<Map<String, dynamic>> allGames = docData.entries
          .where((entry) => entry.value is List)
          .expand((entry) => (entry.value as List).whereType<Map<String, dynamic>>())
          .toList();

      if (type != "all") {
        allGames = allGames.where((game) => game["type"]?.toString() == type).toList();
      }

      if (allGames.isEmpty) {
        return const Center(child: Text("No history found"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: allGames.length,
        itemBuilder: (context, index) {
          var game = allGames[index];
          return _buildHistoryItem(
            title: game['game_name'] ?? 'Unknown',
            date: (game['play_at'] as Timestamp?)?.toDate().toString() ?? 'No date',
            imagePath: game['image_game'] ?? '',
            isDownload: game['isDownload'] ?? false,
          );
        },
      );
    },
  );
}
  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String imagePath,
    required bool isDownload,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/photomain.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF0066FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (isDownload) {
                  print("Download $title");
                } else {
                  print("Play $title");
                }
              },
              icon: Icon(
                isDownload ? Icons.download : Icons.play_arrow,
                color: Colors.white,
                size: 29,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
