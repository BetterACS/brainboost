import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/history_item.dart';

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
      ),
    );
  }

  Widget _buildAllTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        HistoryItem(
          title: "World war 2",
          date: "16 Nov 2024",
          imagePath: 'assets/images/photomain.png',
          isDownload: false,
          onPressed: () => print("Play World war 2"),
        ),
        HistoryItem(
          title: "Object oriented..",
          date: "16 Nov 2024",
          imagePath: 'assets/images/photomain3.png',
          isDownload: false,
          onPressed: () => print("Play Object oriented.."),
        ),
        HistoryItem(
          title: "Software Engine.",
          date: "11 Dec 2024",
          imagePath: 'assets/images/photomain3.png',
          isDownload: false,
          onPressed: () => print("Play Software Engine."),
        ),
        HistoryItem(
          title: "ประวัติศาสตร์",
          date: "16 Nov 2024",
          imagePath: 'assets/images/iconhistory.png',
          isDownload: true,
          onPressed: () => print("Download ประวัติศาสตร์"),
        ),
      ],
    );
  }

  Widget _buildGameTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        HistoryItem(
          title: "World war 2",
          date: "16 Nov 2024",
          imagePath: 'assets/images/photomain.png',
          isDownload: false,
          onPressed: () => print("Play World war 2"),
        ),
        HistoryItem(
          title: "Object oriented..",
          date: "16 Nov 2024",
          imagePath: 'assets/images/photomain3.png',
          isDownload: false,
          onPressed: () => print("Play Object oriented.."),
        ),
        HistoryItem(
          title: "Software Engine..",
          date: "11 Dec 2024",
          imagePath: 'assets/images/photomain3.png',
          isDownload: false,
          onPressed: () => print("Play Software Engine.."),
        ),
      ],
    );
  }

  Widget _buildSummarizeTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        HistoryItem(
          title: "ประวัติศาสตร์",
          date: "16 Nov 2024",
          imagePath: 'assets/images/iconhistory.png',
          isDownload: true,
          onPressed: () => print("Download ประวัติศาสตร์"),
        ),
      ],
    );
  }
}