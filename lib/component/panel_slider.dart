import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/services/user.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';

class PanelSlider extends StatelessWidget {
  final UserServices userServices = UserServices();
  List<GamesType> games;
  int currentPage;
  void Function(double) slidePanelFunction;

  PanelSlider(
      {Key? key,
      required this.games,
      required this.currentPage,
      required this.slidePanelFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(40.0),
      topRight: Radius.circular(40.0),
    );

    return SlidingUpPanel(
      header: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.only(top: 8),
            height: 4,
            width: 160,
            decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                )),
          ),
        ),
      ),
      onPanelSlide: (double value) => slidePanelFunction(value),
      minHeight: games[currentPage].played_history.isEmpty ? 172 : 240,
      maxHeight: 780,
      borderRadius: radius,

      //
      // Panel
      panel: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: radius,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 390,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Colors.white, width: 2),
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
                  OutlinedButton(
                    onPressed: () {
                      // Handle "Add Lecture"
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Colors.white, width: 2),
                      minimumSize: const Size(160, 40),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      "Add Lecture",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 14),
                  width: 340,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color(0xFFECF5FF),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: games[currentPage].played_history.isEmpty
                          ? [
                              const Text(
                                "No play history yet",
                                style: TextStyle(
                                  color: Color(0xFF05235F),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]
                          : List.generate(
                              games[currentPage].played_history.length,
                              (index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: Color(0xFF05235F),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundImage: AssetImage(
                                            'assets/images/profile.jpg'),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      games[currentPage]
                                          .played_history[index]['score']
                                          .toString(),
                                      style: TextStyle(
                                        color: Color(0xFF05235F),
                                        fontSize: 18,
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
              ),
              Center(
                  child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 14),
                width: 340,
                height: 86,
                child: ElevatedButton(
                  onPressed: () => context.push(Routes.playGamePage, extra: {
                    'games': games[currentPage].gameList,
                    'reference': games[currentPage].ref
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
              ))
            ],
          )),
      collapsed: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 4),
            height: 4,
            width: 160,
            decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                )),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: radius,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  games[currentPage].played_history.isEmpty
                      ? "No played history"
                      : "Played history",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                    height: games[currentPage].played_history.isEmpty ? 0 : 20),
                SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          games[currentPage].played_history.length,
                          (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: AssetImage(
                                          'assets/images/profile.jpg'),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    games[currentPage]
                                        .played_history[index]['score']
                                        .toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
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
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
