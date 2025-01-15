import 'package:brainboost/component/colors.dart';
import 'package:brainboost/component/navbar.dart';
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'History',
            style: TextStyle(
              color: AppColors.buttonText,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18.0),
                  bottomRight: Radius.circular(18.0),
                ),
              ),
              child: const TabBar(
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
        ),
        body: TabBarView(
          children: [
            _buildAllTab(),
            _buildGameTab(),
            _buildSummarizeTab(),
          ],
        ),
        // bottomNavigationBar: const Navbar(),
      ),
    );
  }

  Widget _buildAllTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHistoryItem(
          title: "World war 2",
          date: "16 Nov 2024",
          imagePath: 'assets/images/photomain.png',
          isDownload: false,
        ),
        _buildHistoryItem(
          title: "Object oriented..",
          date: "16 Nov 2024",
          imagePath: 'assets/images/photomain3.png',
          isDownload: false,
        ),
        _buildHistoryItem(
          title: "Software Engine.",
          date: "11 Dec 2024",
          imagePath: 'assets/images/photomain3.png',
          isDownload: false,
        ),
        _buildHistoryItem(
          title: "ประวัติศาสตร์",
          date: "16 Nov 2024",
          imagePath: 'assets/images/iconhistory.png',
          isDownload: true,
        ),
      ],
    );
  }

  // Tab สำหรับ Game
  Widget _buildGameTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHistoryItem(
          title: "World war 2",
          date: "16 Nov 2024",
          imagePath: 'assets/images/photomain.png',
          isDownload: false,
        ),
        _buildHistoryItem(
          title: "Object oriented..",
          date: "16 Nov 2024",
          imagePath: 'assets/images/photomain3.png',
          isDownload: false,
        ),
        _buildHistoryItem(
          title: "Sofeware Enigine..",
          date: "11 Dec 2024",
          imagePath: 'assets/images/photomain3.png',
          isDownload: false,
        ),
      ],
    );
  }

  Widget _buildSummarizeTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildHistoryItem(
          title: "ประวัติศาสตร์",
          date: "16 Nov 2024",
          imagePath: 'assets/images/iconhistory.png',
          isDownload: true,
        ),
      ],
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
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image, size: 80, color: Colors.grey);
              },
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
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
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
