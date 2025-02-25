import 'dart:ui';

import 'package:brainboost/component/colors.dart';
import 'package:brainboost/screens/creategame.dart';
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
   double _blueHeight = 250;
  bool _showButtons = false;
  int _currentPage = 0;

  final List<String> titles = [
    "Software Engineering",
    "Cybersecurity",
    "Data Science",
    ""
  ];

  final List<String> imagePaths = [
    'assets/images/photomain.png',
    'assets/images/photomain2.png',
    'assets/images/photomain3.png',
    'assets/images/Add.png'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showButtons) {
        setState(() {
           _blueHeight = 250 + _scrollController.offset.clamp(0, 100);
          _showButtons = true;
        });
      } else if (_scrollController.offset <= 200 && _showButtons) {
        setState(() {
           _blueHeight = 250 + _scrollController.offset.clamp(0, 100);
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
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        title: const Text(""),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: _currentPage == titles.length - 1
                ? const ClampingScrollPhysics()
                : const BouncingScrollPhysics(),
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.neutralBackground,
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
                        color: AppColors.cardBackground,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 400,
                    width: 400,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.75),
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: imagePaths.length,
                      itemBuilder: (context, index) {
                        bool isSelected = index == _currentPage;
                        bool isAddButton = index == imagePaths.length - 1;

                        double selectedSize = isSelected ? 270 : 200;
                        double backgroundSize = selectedSize + 50;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.symmetric(
                              horizontal: isSelected ? 10 : 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!isAddButton)
                                Container(
                                  width: backgroundSize,
                                  height: backgroundSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade300,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ]
                                        : [],
                                  ),
                                ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(150),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      imagePaths[index],
                                      width: selectedSize,
                                      height: selectedSize,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error,
                                            size: 80, color: Colors.red);
                                      },
                                    ),
                                    if (!isSelected)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.white.withOpacity(0.1),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 1.0, sigmaY: 1.0),
                                            child: Container(
                                                color: Colors.transparent),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (_currentPage == titles.length - 1)
                    Column(
                      children: [
                        const Text(
                          "Learn more about Lecture?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UploadFileScreen(),
                              ),
                            );
                          },
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
                                'assets/images/game.svg',
                                width: 24,
                                height: 24,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Create Summary',
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
                  else if (_currentPage != titles.length - 1 && !_showButtons)
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.push(Routes.playGamePage),
                          icon: SvgPicture.asset(
                            'assets/images/game.svg',
                            width: 24,
                            height: 24,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Play",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neutralBackground,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "You have played 2 days ago",
                          style: TextStyle(
                            color: AppColors.gray2,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  if (_currentPage != titles.length - 1)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        if (_showButtons)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.buttonText,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    side: const BorderSide(
                                        color: Colors.white, width: 2),
                                    minimumSize: const Size(160, 40),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  ),
                                  child: const Text(
                                    "Re version",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.buttonText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.buttonText,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    side: const BorderSide(
                                        color: Colors.white, width: 2),
                                    minimumSize: const Size(160, 40),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  ),
                                  child: const Text(
                                    "Add lecture",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.buttonText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              width: constraints.maxWidth,
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 110, 
                                    height: 4, 
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          15), 
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
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
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        if (_showButtons)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neutralBackground,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  minimumSize:
                                      Size(constraints.maxWidth * 0.8, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  'assets/images/game.svg',
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Play",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          )
                      ],
                    ),
                  const SizedBox(height: 400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
