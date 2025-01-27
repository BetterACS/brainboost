import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyGames extends StatefulWidget {
  const MyGames({super.key});

  @override
  State<MyGames> createState() => _MyGamesState();
}

class _MyGamesState extends State<MyGames> {
  final PageController _pageController = PageController();
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

  final List<String> descriptions = [
    "Learn coding principles and software development techniques",
    "Explore network security and ethical hacking strategies", 
    "Master data analysis and machine learning algorithms"
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Mon Chinawat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              titles[_currentPage],
              style: const TextStyle(
                color: AppColors.containerBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 5),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                descriptions[_currentPage],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.containerBackground,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            SizedBox(
              height: 180,
              width: 180,
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
                      color: Color(0xFFD9D9D9),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        imagePaths[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 60, color: Colors.red);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/images/game.svg',
                width: 25,
                height: 25,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                  borderRadius: BorderRadius.circular(30),
                ),
                side: BorderSide(
                  color: AppColors.neutralBackground,
                  width: 2,
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            const Text(
              "You have played 2 days ago",
              style: TextStyle(
                color: AppColors.containerBackground,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 40), // เพิ่มระยะห่างตรงนี้
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                    bottom: Radius.zero,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Scoreboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: Center(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundImage:
                                          AssetImage('assets/images/profile.jpg'),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "82",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}