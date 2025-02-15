import 'dart:math';
import 'dart:ui';
import 'package:brainboost/screens/history.dart';
import 'package:brainboost/services/games.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/component/cards/profile.dart';
import 'package:brainboost/screens/creategame.dart';
import 'package:brainboost/services/user.dart';
import 'package:brainboost/component/history_item.dart'; // Add this import
import 'package:brainboost/component/circular_page_chart.dart';

var histories = [
  HistoryItem(
    title: "World war 2",
    date: "11 Dec 2024",
    imagePath: 'assets/images/photomain.png',
    isDownload: false,
    onPressed: () => print("Play Software Engine.."),
  ),
  HistoryItem(
    title: "World war 2",
    date: "11 Dec 2024",
    imagePath: 'assets/images/photomain.png',
    isDownload: false,
    onPressed: () => print("Play Software Engine.."),
  )
];

class _MouseScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isProfileLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentBackground,
      body: ScrollConfiguration(
        behavior: _MouseScrollBehavior(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const ProfileContainer(),
              const SizedBox(height: 20),
              _buildPageView(),
              const SizedBox(height: 10),
              _buildPageIndicator(),
              const SizedBox(height: 20),
              _buildActionButtons(),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Future<DocumentSnapshot> fetchUsername() async {
    final String? email = UserServices().getCurrentUserEmail();
    final DocumentSnapshot userDoc =
        await UserServices().users.doc(email).get();

    setState(() {
      isProfileLoaded = true;
    });
    return userDoc;
  }

  Widget _buildProfileSection() {
    final String? email = UserServices().getCurrentUserEmail();
    if (email == null) return const Text("User not logged in");

    return FutureBuilder<DocumentSnapshot>(
      future: fetchUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            isProfileLoaded == false) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("User not found");
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final username = userData['username'] ?? 'Guest';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neutralBackground,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                username,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageView() {
    return SizedBox(
      height: 330,
      width: 300,
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildCircularChartPage(),
          _buildRecentGamePage(),
        ],
      ),
    );
  }

  bool isLoadCircle = false;
  int numberGames = 0;
  int correctQuestion = 0;

  Future<void> fetchGamePerformance() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || isLoadCircle == true) return;

    List<String> gamesPath =
        await UserServices().getGames(email: email as String);
    int _games = 0;
    int _score = 0;

    for (String gamePath in gamesPath) {
      Map<String, dynamic> game =
          await GameServices().getGame(path: gamePath) as Map<String, dynamic>;

      _games += game['game_list'].length as int;
      int currentScore = 0;
      for (Map<String, dynamic> playedHistory in game['played_history']) {
        DocumentReference userPath = playedHistory['player'];
        String player = userPath.path.split("/")[1];

        if (player == email) {
          if (playedHistory['score'] > currentScore) {
            currentScore = playedHistory['score'];
          }
        }
      }
      _score += currentScore;
    }

    print(_score);
    setState(() {
      isLoadCircle = true;
      numberGames = _games;
      correctQuestion = _score;
    });
  }

  Widget _buildCircularChartPage() {
    return FutureBuilder<void>(
      future: fetchGamePerformance(),
      builder: (context, snapshot) {
        if (isLoadCircle)
          return Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(285, 285),
                    painter: CircularChartPainter(
                        (correctQuestion / numberGames) * 100),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Success rate",
                        style: TextStyle(
                          color: AppColors.buttonText,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        ((correctQuestion / numberGames) * 100)
                                .toStringAsFixed(2) +
                            "%",
                        style: TextStyle(
                          color: AppColors.buttonText,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "out of ${numberGames} questions",
                        style: TextStyle(
                          color: AppColors.buttonText,
                          fontSize: 17.59,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        else
          return Center(
              child: SizedBox(
            height: 300,
            width: 300,
          ));
      },
    );
  }

  // }

  Widget _buildRecentGamePage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 300,
          width: 300,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.circleGradient,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 35),
            ),
            const Text(
              "Recent Game",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "World War 2",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: Image.asset(
                'assets/images/photomain.png',
                height: 140,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 80, color: Colors.red);
                },
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "70 / 100",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: ElevatedButton(
                onPressed: () {
                  print("Replay pressed");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: AppColors.neutralBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                ),
                child: const Text(
                  "Replay",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: _currentPage == index ? 16 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.gradient2 : AppColors.gray,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            icon: Icons.games_rounded,
            text: "Create Game",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateGameScreen()),
              );
            },
          ),
          // _buildButton(
          //   icon: Icons.summarize,
          //   text: "Create Summary",
          //   onPressed: () {
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(builder: (context) => const CreateSummary()),
          //     // );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "History",
                style: TextStyle(
                  color: AppColors.gradient1,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const History()),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      "View all",
                      style: TextStyle(
                        color: AppColors.gray2,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.gray2,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var history in histories) history,

          // HistoryItem(
          //   title: "World war 2",
          //   date: "11 Dec 2024",
          //   imagePath: 'assets/images/photomain.png',
          //   isDownload: false,
          //   onPressed: () => print("Play Software Engine.."),
          // ),
          // HistoryItem(
          //   title: "Object oriented..",
          //   date: "11 Dec 2024",
          //   imagePath: 'assets/images/photomain3.png',
          //   isDownload: false,
          //   onPressed: () => print("Play Software Engine.."),
          // ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(48),
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        height: 70,
        width: 200,
        decoration: const BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(48),
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              left: -12,
              child: Transform.rotate(
                angle: 25 * pi / 180,
                child: Icon(
                  icon,
                  color: AppColors.accentBackground,
                  size: 54,
                ),
              ),
            ),
            Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
