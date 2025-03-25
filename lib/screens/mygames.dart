import 'dart:ui';

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
import 'package:brainboost/component/panel_slider.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:brainboost/services/user.dart';
import 'package:brainboost/services/games.dart';

class MyGames extends StatefulWidget {
  const MyGames({super.key});

  @override
  State<MyGames> createState() => _MyGamesState();
}

class _MyGamesState extends State<MyGames> {
  final PageController _pageController = PageController();

  final UserServices userServices = UserServices();

  bool _isLoadedGames = false;

  int _currentPage = 0;
  List<GamesType> games = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadGamesMethod() async {
    if (_isLoadedGames) return;

    if (!_isLoadedGames && games.length > 0) {
      setState(() {
        games = [];
      });
      return;
    }

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

    
    setState(() {
      games = _games.reversed.toList();
      _isLoadedGames = true;
    });
  }

  double _slideUpPanelValue = 0.0;
  final double slideValueThreshold = 0.4;
  void toggleSlideUpPanel(double value) {
    setState(() {
      _slideUpPanelValue = value;
    });
  }

  @override
  void dispose() {
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
              backgroundColor: AppColors.mainColor,
              appBar: AppBar(
                title: const Text(""),
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              body: Stack(
                children: [
                  if (_currentPage < games.length)
                    PanelSlider(
                      games: games,
                      currentPage: _currentPage,
                      slidePanelFunction: toggleSlideUpPanel,
                    ),
                  Column(
                    children: <Widget>[
                      //
                      //  Player Name
                      const ProfileContainer(),
                      const SizedBox(height: 40),

                      //
                      // Game Title
                      AnimatedContainer(
                        duration: Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          _currentPage < games.length
                              ? games[_currentPage].name
                              : "",
                          style: TextStyle(
                            color: _slideUpPanelValue <= slideValueThreshold
                                ? AppColors.cardBackground
                                : Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Stack(
                        children: [
                          //
                          // Game Icon
                          SizedBox(
                            height: 300,
                            // width: 400,
                            width: double.infinity,
                            child: PageView.builder(
                              controller: PageController(viewportFraction: 0.7),
                              onPageChanged: (index) {
                                bool isChangePanelValue = index == games.length;

                                if (isChangePanelValue) {
                                  toggleSlideUpPanel(0.0);
                                }
                                setState(() {
                                  _currentPage = index;
                                });
                                print("Current Page: $_currentPage");
                              },
                              itemCount: games.length + 1,
                              itemBuilder: (context, index) {
                                bool isSelected = index == _currentPage;
                                double selectedSize = isSelected ? 340 : 300;
                                double backgroundSize = isSelected ? 400 : 400;

                                bool isAddButton = index == games.length;

                                return Transform.scale(
                                  scale: isSelected ? 1.0 : 0.85,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    transform: Matrix4.identity()
                                      ..translate(0.0, isSelected ? -2.0 : 12.0,
                                          isSelected ? 10.0 : 0.0),
                                    child: Stack(
                                      children: [
                                        if (index < games.length)
                                          Positioned(
                                            height: isSelected ? 265 : 240,
                                            top: 26,
                                            left: 0,
                                            right: 0,
                                            child: Center(
                                              child: ClipOval(
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 150),
                                                  width: backgroundSize,
                                                  color: _slideUpPanelValue <=
                                                          slideValueThreshold
                                                      ? Colors.grey.shade300
                                                      : Color(0xFF102247),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(150),
                                          child: Image.asset(
                                            isAddButton
                                                ? "assets/images/Add.png"
                                                : "assets/images/${games[index].icon}",
                                            width: selectedSize,
                                            height: selectedSize,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.error,
                                                  size: 80, color: Colors.red);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Options Icons
                          if (_slideUpPanelValue > slideValueThreshold)
                            Center(
                                child: Container(
                                    height: 32,
                                    width: 32,
                                    margin:
                                        EdgeInsets.only(right: 172, top: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                        child: IconButton(
                                            iconSize: 16,
                                            color: Colors.white,
                                            onPressed: () => {
                                                  GameServices().deleteGame(
                                                      path: games[_currentPage]
                                                          .ref,
                                                      email: FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .email as String),

                                                  setState(() => _isLoadedGames =
                                                      false), // ลบเกมจาก Firebase
                                                  // _isLoadedGames = false,
                                                },
                                            icon: Icon(Icons.delete))))),
                          if (_slideUpPanelValue > slideValueThreshold)
                            Center(
                                child: Container(
                                    height: 32,
                                    width: 32,
                                    margin:
                                        EdgeInsets.only(right: 246, top: 48),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                        child: IconButton(
                                            iconSize: 16,
                                            color: Colors.white,
                                            onPressed: () => print("Share"),
                                            icon: Icon(Icons.share))))),
                        ],
                      ),
                      // Description
                      const SizedBox(height: 5),
                      if (_currentPage >= games.length)

                        //
                        // Create New Game Button
                        Column(
                          children: [
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
                                backgroundColor: AppColors.neutralBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )

                      //
                      // Play Game Button
                      else if (_currentPage != games.length &&
                          _slideUpPanelValue <= slideValueThreshold)
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () => context.push(Routes.playGamePage,
                                  extra: {
                                    'games': games[_currentPage].gameList,
                                    'reference': games[_currentPage].ref
                                  }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.neutralBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
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
                                    'Play Game',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                    ],
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
          const SizedBox(width: 4),
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
