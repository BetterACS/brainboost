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
  final PageController _pageController = PageController(viewportFraction: 0.7);
  final UserServices userServices = UserServices();
  final GameServices gameServices = GameServices(); // Instantiate GameServices

  bool _isLoadedGames = false;
  int _currentPage = 0;
  List<GamesType> games = [];

  bool _isEditingTitle = false;
  final TextEditingController _titleEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleEditController.addListener(() {
      // Optional: Add listener if needed for real-time validation or other logic
    });
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

    final List<GamesType> _games = [];
    for (var path in paths) {
      print("Path: $path");
      final gameData = await GameServices().getGame(path: path) as Map<String, dynamic>?; // Make nullable
      if (gameData != null) { // Check if data is not null
         _games.add(GamesType.fromMap(gameData, path));
      } else {
        print("Warning: Could not load game data for path: $path");
      }
    }

    setState(() {
      games = _games.reversed.toList();
      _isLoadedGames = true;
      _isEditingTitle = false; // Ensure editing is off on reload
    });
  }

  double _slideUpPanelValue = 0.0;
  final double slideValueThreshold = 0.4;
  void toggleSlideUpPanel(double value) {
    setState(() {
      _slideUpPanelValue = value;
      if (_isEditingTitle && _slideUpPanelValue < slideValueThreshold) {
        _isEditingTitle = false;
        _titleEditController.clear(); // Clear controller text
      }
    });
  }

  Future<void> _saveTitleChanges() async {
    if (_currentPage >= games.length) return; // Shouldn't happen, but safe check

    final newTitle = _titleEditController.text.trim();
    final currentGame = games[_currentPage];

    if (newTitle.isNotEmpty && newTitle != currentGame.name) {
      try {
        await gameServices.updateGameName(
            path: currentGame.ref, newName: newTitle);

        setState(() {
          games[_currentPage] = GamesType(
            ref: currentGame.ref,
            author: currentGame.author,
            name: newTitle, // Update the name here
            description: currentGame.description,
            icon: currentGame.icon,
            gameList: currentGame.gameList,
            media: currentGame.media,
            played_history: currentGame.played_history,
          );
          _isEditingTitle = false; // Exit editing mode
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Game title updated!'), duration: Duration(seconds: 2),),
        );
      } catch (e) {
         print("Error saving title: $e");
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to update title: $e'), duration: Duration(seconds: 2)),
         );
         setState(() {
           _isEditingTitle = false; // Exit editing on error for simplicity
         });
      }
    } else {
      setState(() {
        _isEditingTitle = false;
      });
    }
     _titleEditController.clear(); // Clear controller after saving or cancelling
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleEditController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: _loadGamesMethod(),
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isLoadedGames) {
             return Scaffold(
                backgroundColor: AppColors.mainColor,
                body: Center(child: CircularProgressIndicator(color: Colors.white)),
             );
          }
          if (snapshot.hasError) {
             return Scaffold(
                backgroundColor: AppColors.mainColor,
                body: Center(child: Text('Error loading games: ${snapshot.error}', style: TextStyle(color: Colors.white))),
             );
          }

          if (_isLoadedGames) {
            final bool canEditTitle = _isEditingTitle && _currentPage < games.length;
            final bool showTitleEditor = canEditTitle && _slideUpPanelValue >= slideValueThreshold;
            final bool showNormalTitle = !showTitleEditor && _currentPage < games.length;
            final Color titleColor = _slideUpPanelValue <= slideValueThreshold
                                  ? AppColors.cardBackground
                                  : Colors.white;

            return Scaffold(
              backgroundColor: AppColors.mainColor,
              appBar: AppBar(
                title: const Text(""),
                elevation: 0,
                backgroundColor: Colors.transparent,
                actions: [
                   if (!_isLoadedGames)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      )
                   else IconButton(
                      icon: Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                         if (_isEditingTitle) _saveTitleChanges();
                         setState(() {
                            _isLoadedGames = false;
                            games = [];
                            _currentPage = 0;
                         });
                      },
                      tooltip: 'Refresh Games',
                   ),
                ],
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
                      const ProfileContainer(),
                      const SizedBox(height: 40),

                      GestureDetector(
                        onTap: () {
                          if (!_isEditingTitle &&
                              _currentPage < games.length &&
                              _slideUpPanelValue >= slideValueThreshold) {
                            setState(() {
                              _isEditingTitle = true;
                              _titleEditController.text = games[_currentPage].name;
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: showTitleEditor
                                  ? TextField(
                                      controller: _titleEditController,
                                      autofocus: true,
                                      style: TextStyle(
                                        color: titleColor,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLength: 20, // Set max characters to 40
                                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => 
                                          // Only show counter if approaching limit
                                          currentLength > 12 ? Text(
                                            '$currentLength/$maxLength',
                                            style: TextStyle(
                                              color: currentLength >= 20 ? Colors.red : Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ) : null,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        hintText: "Enter new title",
                                        hintStyle: TextStyle(
                                          color: titleColor.withOpacity(0.5),
                                          fontSize: 25,
                                          fontWeight: FontWeight.normal,
                                        )
                                      ),
                                      onSubmitted: (_) => _saveTitleChanges(),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_currentPage < games.length && 
                                            _slideUpPanelValue >= slideValueThreshold && 
                                            !_isEditingTitle)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 4.0),
                                            child: Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: titleColor,
                                            ),
                                          ),
                                        
                                        Text(
                                          showNormalTitle ? games[_currentPage].name : "",
                                          style: TextStyle(
                                            color: titleColor,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                              
                              if (_isEditingTitle)
                                IconButton(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: titleColor,
                                    size: 30,
                                  ),
                                  onPressed: _saveTitleChanges,
                                  tooltip: 'Save title changes',
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Stack(
                        children: [
                          SizedBox(
                            height: 300,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                if (_isEditingTitle) {
                                  _saveTitleChanges();
                                }

                                bool isChangePanelValue = index == games.length;
                                if (isChangePanelValue && _slideUpPanelValue > 0) {
                                  toggleSlideUpPanel(0.0);
                                }

                                setState(() {
                                  _currentPage = index;
                                   _isEditingTitle = false;
                                   _titleEditController.clear();
                                });
                                print("Current Page: $_currentPage");
                              },
                              itemCount: games.isNotEmpty ? games.length + 1 : 1,
                              itemBuilder: (context, index) {
                                if (games.isEmpty && index == 0) {
                                     return _buildAddGameCard(true);
                                }

                                bool isAddButton = index == games.length;
                                bool isSelected = index == _currentPage;

                                return isAddButton
                                       ? _buildAddGameCard(isSelected)
                                       : _buildGameCard(index, isSelected);

                              },
                            ),
                          ),

                          if (_slideUpPanelValue > slideValueThreshold && _currentPage < games.length && !_isEditingTitle)
                            Positioned.fill(
                              child: _buildOptionIcons(),
                            ),
                          
                        ],
                      ),
                      const SizedBox(height: 5),
                      if (_currentPage >= games.length)
                        _buildCreateGameButton()
                      else if (_currentPage < games.length && _slideUpPanelValue <= slideValueThreshold)
                        _buildPlayGameButton()
                    ],
                  ),
                ],
              ),
            );
          } else {
             return Scaffold(
                backgroundColor: AppColors.mainColor,
                 appBar: AppBar(
                   title: const Text(""),
                   elevation: 0,
                   backgroundColor: Colors.transparent,
                    actions: [
                       Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      )
                    ]
                 ),
                body: Center(child: Text("Loading your games...", style: TextStyle(color: Colors.white))),
             );
          }
        });
  }

  Widget _buildGameCard(int index, bool isSelected) {
    double backgroundSize = 300;

      return Transform.scale(
         scale: isSelected ? 1.0 : 0.85,
         child: AnimatedContainer(
             duration: const Duration(milliseconds: 300),
             transform: Matrix4.identity()
                ..translate(0.0, isSelected ? -2.0 : 12.0, isSelected ? 10.0 : 0.0),
             child: Stack(
                 alignment: Alignment.center,
                 children: [
                     Positioned(
                         height: isSelected ? 265 : 240,
                         top: 26,
                         left: 0,
                         right: 0,
                         child: Center(child: ClipOval(
                            child: AnimatedContainer(
                               duration: const Duration(milliseconds: 150),
                               width: backgroundSize,
                               color: _slideUpPanelValue <= slideValueThreshold
                                   ? Colors.grey.shade300
                                   : Color(0xFF102247),
                            ),
                         ),
                        ),
                     ),
                      SizedBox(
                        child: Transform.scale(
                          scale: 1.08,
                          child: Image.asset(
                            games[index].icon,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'animations/map2.GIF',
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                      ),
                 ],
             ),
         ),
      );
  }

   Widget _buildAddGameCard(bool isSelected) {
      return Transform.scale(
         scale: isSelected ? 1.0 : 0.85,
         child: AnimatedContainer(
             duration: const Duration(milliseconds: 300),
             transform: Matrix4.identity()
                ..translate(0.0, isSelected ? -2.0 : 12.0, isSelected ? 10.0 : 0.0),
             child: Image.asset(
                 "assets/images/Add.png",
             ),
         ),
      );
   }

  Widget _buildOptionIcons() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 86,
          top: 16,
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))]
            ),
            child: Center(
              child: IconButton(
                iconSize: 16,
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                tooltip: 'Delete Game',
                onPressed: () async {
                  if (_currentPage < games.length) {
                    final bool confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete "${games[_currentPage].name}"? This cannot be undone.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: Text('Delete'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        );
                      },
                    ) ?? false;

                    if (confirmDelete) {
                      try {
                        String gameRefToDelete = games[_currentPage].ref;
                        String userEmail = FirebaseAuth.instance.currentUser!.email!;

                        await gameServices.deleteGame(
                          path: gameRefToDelete,
                          email: userEmail,
                        );

                        setState(() {
                           _isLoadedGames = false;
                           _slideUpPanelValue = 0;
                           toggleSlideUpPanel(0.0);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Game deleted.'), duration: Duration(seconds: 2)),
                        );

                      } catch (e) {
                         print("Error deleting game: $e");
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Error deleting game: $e'), duration: Duration(seconds: 2)),
                         );
                         if (!mounted) return;
                           setState(() {
                             _isLoadedGames = true;
                           });
                      }
                    }
                  }
                },
                icon: Icon(Icons.delete),
              ),
            ),
          ),
        ),
        Positioned(
          left: 42,
          top: 64,
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
               boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))]
            ),
            child: Center(
              child: IconButton(
                iconSize: 16,
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                tooltip: 'Share Game (Not Implemented)',
                onPressed: () {
                  print("Share button pressed for ${games[_currentPage].name}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Share feature coming soon!'), duration: Duration(seconds: 1)),
                    );
                },
                icon: Icon(Icons.share),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateGameButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
             if (_isEditingTitle) _saveTitleChanges();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UploadFileScreen(),
              ),
            ).then((_) {
               setState(() { _isLoadedGames = false; });
            });
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
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
    );
  }

  Widget _buildPlayGameButton() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           ElevatedButton(
             onPressed: () {
                if (_isEditingTitle) _saveTitleChanges();
                 if (_currentPage < games.length) {
                    context.push(Routes.playGamePage, extra: {
                       'games': games[_currentPage].gameList,
                       'reference': games[_currentPage].ref,
                       'gameName': games[_currentPage].name
                    });
                 } else {
                    print("Error: Tried to play game with invalid index $_currentPage");
                 }
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
                     colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
    );
  }
}
