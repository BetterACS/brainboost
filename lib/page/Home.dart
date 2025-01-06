import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:brainboost/component/navbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  bool _showButtons = false;
  int _currentPage = 0;

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
      backgroundColor: AppColors.accentBackground,
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
                      color: AppColors.primaryBackground,
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
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  ),
                  const SizedBox(height: 10),
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
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 300,
                              width: 300,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.circleGradient),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Recent Game",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 0),
                                const Text(
                                  "World war 2",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(150),
                                  child: Image.asset(
                                    imagePaths[index],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error,
                                          size: 80, color: Colors.red);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "70 / 100",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    print("Replay pressed");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Replay"),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Create Game Button
                        Container(
                          decoration: BoxDecoration(
                            gradient:
                                AppColors.buttonGradient, // Apply the gradient
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.summarize,
                                color: Colors.white),
                            label: const Text("Create Game"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent, // Text color
                              shadowColor:
                                  Colors.transparent, // Remove button shadow
                            ),
                          ),
                        ),
                        // Create Summary Button
                        Container(
                          decoration: BoxDecoration(
                            gradient:
                                AppColors.buttonGradient, // Apply the gradient
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.summarize,
                                color: Colors.white),
                            label: const Text("Create Summary"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent, // Text color
                              shadowColor:
                                  Colors.transparent, // Remove button shadow
                            ),
                          ),
                        )
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
      bottomNavigationBar: Navbar(),
    );
  }
}
