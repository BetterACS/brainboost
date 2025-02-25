import 'package:brainboost/component/colors.dart';
import 'package:brainboost/screens/creategame.dart';
import 'package:brainboost/models/games.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/component/cards/profile_header.dart'; // เพิ่ม import นี้
import 'package:firebase_auth/firebase_auth.dart';

import 'package:brainboost/services/user.dart';
import 'package:brainboost/services/games.dart';

class MyGames extends StatefulWidget {
  const MyGames({super.key});

  @override
  State<MyGames> createState() => _MyGamesState();
}

class _MyGamesState extends State<MyGames> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  final UserServices userServices = UserServices();

  bool _showButtons = false;
  bool _isLoadedGames = false;

  int _currentPage = 0;
  List<GamesType> games = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showButtons) {
        setState(() {
          _showButtons = true;
        });
      } else if (_scrollController.offset <= 200 && _showButtons) {
        setState(() {
          _showButtons = false;
        });
      }
    });
  }

  Future<void> _loadGamesMethod() async {
    if (_isLoadedGames) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      GoRouter.of(context).go('/login');
      return;
    }

    final String email = user.email as String;
    final List<String> paths = await userServices.getGames(email: email);
    // var games = [];

    final List<GamesType> _games = [];
    for (var path in paths) {
      print("Path: $path");
      _games.add(GamesType.fromMap(
          await GameServices().getGame(path: path) as Map<String, dynamic>,
          path));
    }

    print(games);
    setState(() {
      games = _games;
      _isLoadedGames = true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _loadGamesMethod(),
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (_isLoadedGames) {
            return Scaffold(
              backgroundColor: AppColors.primaryBackground,
              appBar: AppBar(
                title: const Text(""),
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: _currentPage < games.length
                        ? const ClampingScrollPhysics()
                        : const BouncingScrollPhysics(),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          //
                          //  Player Name
                          const ProfileContainer(),
                          const SizedBox(height: 20),

                          //
                          // Game Title
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              _currentPage < games.length
                                  ? games[_currentPage].name
                                  : "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          //
                          // Game Icon
                          SizedBox(
                            height: 300,
                            width: 300,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                                print("Current Page: $_currentPage");
                              },
                              itemCount: games.length + 1,
                              itemBuilder: (context, index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    color: index == games.length
                                        ? Colors.transparent
                                        : const Color.fromARGB(255, 0, 38, 84),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(150),
                                    child: Image.asset(
                                      index >= games.length
                                          ? "assets/images/Add.png"
                                          : "assets/images/${games[index].icon}",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error,
                                            size: 80, color: Colors.red);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Description
                          const SizedBox(height: 5),
                          if (_currentPage >= games.length)

                            //
                            // Create New Game Button
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UploadFileScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.neutralBackground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/game.svg',
                                        width: 24,
                                        height: 24,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Create new game',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else

                            //
                            // Play Game Button
                            Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => context
                                      .push(Routes.playGamePage, extra: {
                                    'games': games[_currentPage].gameList,
                                    'reference': games[_currentPage].ref
                                  }),
                                  icon: SvgPicture.asset(
                                    'assets/images/game.svg',
                                    width: 35,
                                    height: 35,
                                  ),
                                  label: const Text(
                                    "Play",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.buttonText,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    side: BorderSide(
                                      color: AppColors.buttonBorder,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "You have played 2 days ago",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),

                          //
                          // Show Scoreboard when the game is not the last one
                          if (_currentPage < games.length)
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "History",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        height: 120,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: List.generate(
                                                games[_currentPage]
                                                    .played_history
                                                    .length, (index) {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child: Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: CircleAvatar(
                                                        radius: 22,
                                                        backgroundImage: AssetImage(
                                                            'assets/images/profile.jpg'),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      games[_currentPage]
                                                          .played_history[index]
                                                              ['score']
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 400),
                        ],
                      ),
                    ),
                  ),

                  // Show Buttons
                  if (_showButtons)
                    Positioned(
                      bottom: 90,
                      left: 20,
                      right: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.buttonText,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text("Re version"),
                              ),

                              // Delete Game
                              ElevatedButton(
                                onPressed: () async {
                                  String? email =
                                      FirebaseAuth.instance.currentUser!.email;
                                  if (email == null) return;

                                  final List<String> paths =
                                      await userServices.getGames(email: email);
                                  GameServices().deleteGame(
                                      path: paths[_currentPage], email: email);

                                  setState(() {
                                    _isLoadedGames = false;
                                    _currentPage = 0;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.buttonText,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text("Delete game"),
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  // Handle "Add Lecture"
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.buttonText,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text("Add Lecture"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              'assets/images/game.svg',
                              width: 35,
                              height: 35,
                            ),
                            label: const Text(
                              "Play",
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.buttonText,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 240, 239, 240),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}

class IconTitleButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onPressed;

  const IconTitleButton({
    required this.title,
    required this.iconPath,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neutralBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
