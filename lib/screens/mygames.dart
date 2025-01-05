import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';

class MyGames extends StatefulWidget {
  const MyGames({super.key});

  @override
  State<MyGames> createState() => _MyGamesState();
}

class _MyGamesState extends State<MyGames> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  bool _showButtons = false;
  int _currentPage = 0;

  final List<String> titles = [
    "Software Engineering",
    "Cybersecurity",
    "Data Science",
  ];

  final List<String> imagePaths = [
    'assets/images/photomain.png',
    'assets/images/photomain2.png',
    'assets/images/photomain3.png',
  ];

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

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                AssetImage('assets/images/profile.jpg'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Mon Chinawat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      titles[_currentPage],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: imagePaths.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 0, 38, 84),
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: Image.asset(
                              imagePaths[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error,
                                    size: 80, color: Colors.red);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    onPressed: () => context.push(Routes.playGamePage),
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
                          "Scoreboard",
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
                              children: List.generate(5, (index) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 22,
                                          backgroundImage: AssetImage(
                                              'assets/images/profile.jpg'),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "82",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 400),
                ],
              ),
            ),
          ),
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
                    onPressed: () {
                    },
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
                      backgroundColor: const Color.fromARGB(255, 240, 239, 240),
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
      // bottomNavigationBar: Navbar(),
    );
  }
}
