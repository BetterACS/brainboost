import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:brainboost/component/colors.dart';
import 'package:brainboost/component/cards/profile_header.dart';
import 'package:brainboost/component/panel_slider.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/main.dart';
import 'package:brainboost/presentation/bloc/games/games_bloc.dart';
import 'package:brainboost/presentation/bloc/games/games_event.dart';
import 'package:brainboost/presentation/bloc/games/games_state.dart';
import 'package:brainboost/domain/entities/game_entity.dart';
import 'package:brainboost/domain/entities/games_type.dart'; // Add this import for GamesType

class MyGamesPage extends StatefulWidget {
  const MyGamesPage({super.key});

  @override
  State<MyGamesPage> createState() => _MyGamesPageState();
}

class _MyGamesPageState extends State<MyGamesPage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  final PanelController _panelController = PanelController();

  bool _isEditingTitle = false;
  final TextEditingController _titleEditController = TextEditingController();
  final TextEditingController _gameNameTextController = TextEditingController();
  String _newGameTitle = "New Game"; // Default title for new game

  int _currentPage = 0;
  List<GamesTypeEntity> games = [];

  PlatformFile? pickedFile;
  String? fileName;
  String? uploadLink;
  double progress = 0.0;
  bool isUploading = false;
  bool uploadSuccess = false;

  // List to hold available animation icons
  List<String> availableIcons = [];
  bool _isLoadingIcons = false;

  String? lectureUploadLink;
  bool isLectureUploading = false;
  double lectureUploadProgress = 0.0;
  bool lectureUploadSuccess = false;
  String? lectureFileName;

  double _slideUpPanelValue = 0.0;
  final double slideValueThreshold = 0.4;

  @override
  void initState() {
    super.initState();
    _titleEditController.addListener(() {});
    _loadAvailableIcons();
    // Load user games on initialization
    _loadUserGames();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleEditController.dispose();
    _gameNameTextController.dispose();
    super.dispose();
  }

  void _loadUserGames() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      GoRouter.of(context).go('/login');
      return;
    }

    final String email = user.email as String;
    context.read<GamesBloc>().add(GetUserGamesEvent(email));
  }

  void toggleSlideUpPanel(double value) {
    setState(() {
      _slideUpPanelValue = value;
      if (_isEditingTitle && _slideUpPanelValue < slideValueThreshold) {
        _isEditingTitle = false;
        _titleEditController.clear();
      }
    });
  }

  Future<void> _saveTitleChanges() async {
    if (_currentPage >= games.length) {
      // Handle the case when we're on the Add page
      String newTitle = _titleEditController.text.trim();
      if (newTitle.isNotEmpty) {
        setState(() {
          _gameNameTextController.text = newTitle;
          _newGameTitle = newTitle; // Store the new title in our variable
          _isEditingTitle = false;
        });
        return;
      } else {
        // Default to "New Game" if empty
        setState(() {
          _titleEditController.text = AppLocalizations.of(context)!.newGame;
          _gameNameTextController.text = AppLocalizations.of(context)!.newGame;
          _newGameTitle = AppLocalizations.of(context)!.newGame;
          _isEditingTitle = false;
        });
        return;
      }
    }

    final newTitle = _titleEditController.text.trim();
    final currentGame = games[_currentPage];

    if (newTitle.isNotEmpty && newTitle != currentGame.name) {
      try {
        // Update game name using the BLoC
        final User? user = FirebaseAuth.instance.currentUser;
        final String? email = user?.email;

        context.read<GamesBloc>().add(UpdateGameNameEvent(
              gamePath: currentGame.id,
              newName: newTitle,
              userEmail: email,
            ));

        setState(() {
          _isEditingTitle = false;
        });
      } catch (e) {
        print("Error saving title: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update title: $e'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _isEditingTitle = false;
        });
      }
    } else {
      setState(() {
        _isEditingTitle = false;
      });
    }
    _titleEditController.clear();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      return;
    }

    setState(() {
      fileName = result.files.single.name;
      pickedFile = result.files.first;
      uploadSuccess = false;
      isUploading = true;
      uploadLink = null;
      progress = 0.0;
    });

    await uploadFile();
  }

  Future<void> uploadFile() async {
    if (pickedFile == null) {
      print("No file selected for upload.");
      return;
    }

    try {
      // Use BLoC to upload file
      context.read<GamesBloc>().add(UploadFileEvent(
            file: io.File(pickedFile!.path!),
            fileName: pickedFile!.name,
          ));
    } catch (e) {
      print('Error while loading ${e}');
      setState(() {
        isUploading = false;
      });
    }
  }

  void onCreateGamePressed() async {
    if (!uploadSuccess || uploadLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseUploadFile)),
      );
      return;
    }

    // Get the actual game name from the text controller or use the stored variable
    final String gameName = _gameNameTextController.text.isNotEmpty
        ? _gameNameTextController.text
        : _newGameTitle;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    // Create game from PDF using BLoC
    context.read<GamesBloc>().add(CreateGameFromPdfEvent(
          pdfUrl: uploadLink!,
          gameName: gameName,
          userEmail: user.email!,
        ));

    // First update panel state
    if (_panelController.isPanelOpen) {
      _panelController.close();
    }

    // Then reset states
    setState(() {
      uploadLink = null;
      fileName = null;
      pickedFile = null;
      uploadSuccess = false;
      _gameNameTextController.clear();
      _newGameTitle = AppLocalizations.of(context)!.newGame;
      _currentPage = 0;
      _slideUpPanelValue = 0;
      toggleSlideUpPanel(0.0);
    });
  }

  // Method for re-versioning a game
  void onReVersionPressed() async {
    if (_currentPage >= games.length) {
      return;
    }

    final currentGame = games[_currentPage];

    // Check if media URL exists
    if (currentGame.media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.cannotReversion)),
      );
      return;
    }

    // Show confirmation dialog
    final bool confirmReVersion = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.confirmReversion),
              content: Text(
                  '${AppLocalizations.of(context)!.areYouSureReversion} "${currentGame.name}"? ${AppLocalizations.of(context)!.createversion}'),
              actions: <Widget>[
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text(AppLocalizations.of(context)!.reversion),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmReVersion) return;

    String gameName =
        "${currentGame.name} (${AppLocalizations.of(context)!.reversion})";
    // Make gameName length 20 characters
    if (gameName.length > 20) {
      gameName = gameName.substring(0, 20);
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    // Create game from the existing PDF using BLoC
    context.read<GamesBloc>().add(CreateGameFromPdfEvent(
          pdfUrl: currentGame.media,
          gameName: gameName,
          userEmail: user.email!,
        ));

    // First update panel state
    if (_panelController.isPanelOpen) {
      _panelController.close();
    }

    // Then reset states
    setState(() {
      uploadLink = null;
      fileName = null;
      pickedFile = null;
      uploadSuccess = false;
      _gameNameTextController.clear();
      _newGameTitle = AppLocalizations.of(context)!.newGame;
      _currentPage = 0;
      _slideUpPanelValue = 0;
      toggleSlideUpPanel(0.0);
    });
  }

  // Method to load available icons
  Future<void> _loadAvailableIcons() async {
    if (_isLoadingIcons) return;

    setState(() {
      _isLoadingIcons = true;
    });

    try {
      // Load asset manifest to get all animation files
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter for animation files in the animations directory
      List<String> icons = manifestMap.keys
          .where((String key) =>
              key.startsWith('assets/animations/') &&
              (key.endsWith('.gif') || key.endsWith('.GIF')))
          .toList();

      setState(() {
        availableIcons = icons;
        _isLoadingIcons = false;
      });

      print("Loaded ${icons.length} icons");
    } catch (e) {
      print("Error loading icons: $e");
      setState(() {
        _isLoadingIcons = false;
        availableIcons = [
          'assets/animations/map1.GIF',
          'assets/animations/map2.GIF',
        ];
      });
    }
  }

  // Method to update game icon
  Future<void> _updateGameIcon(String newIcon) async {
    if (_currentPage >= games.length) return;

    final currentGame = games[_currentPage];

    try {
      // Update game icon using BLoC
      context.read<GamesBloc>().add(UpdateGameIconEvent(
            gamePath: currentGame.id,
            newIcon: newIcon,
          ));
    } catch (e) {
      print("Error updating icon: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update icon: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to show icon selection modal
  void _showIconSelectionModal() {
    if (_currentPage >= games.length) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Not sure",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _isLoadingIcons
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : availableIcons.isEmpty
                      ? Center(
                          child: Text("No icons available",
                              style: TextStyle(color: Colors.white)))
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: availableIcons.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _updateGameIcon(availableIcons[index]);
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF102247),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    availableIcons[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.white70),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle picking a lecture PDF file
  Future<void> pickLectureFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      print("Lecture file picking cancelled or failed.");
      return;
    }

    print("Picked file: ${result.files.single.name}");

    setState(() {
      lectureFileName = result.files.single.name;
      pickedFile = result.files.first;
      lectureUploadSuccess = false;
      isLectureUploading = true;
      lectureUploadLink = null;
      lectureUploadProgress = 0.0;
    });

    await uploadLectureFile();
  }

  // Method to handle uploading the lecture PDF file
  Future<void> uploadLectureFile() async {
    try {
      // Use BLoC to upload file
      context.read<GamesBloc>().add(UploadFileEvent(
            file: io.File(pickedFile!.path!),
            fileName: "lectures/${pickedFile!.name}",
          ));
    } catch (e) {
      print("Error uploading lecture file: $e");
      setState(() {
        isLectureUploading = false;
      });
    }
  }

  // Method to add the lecture to the existing game
  Future<void> addLectureToExistingGame() async {
    if (!lectureUploadSuccess ||
        lectureUploadLink == null ||
        _currentPage >= games.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Cannot add lecture: Upload failed or invalid game')),
      );
      return;
    }

    final currentGame = games[_currentPage];

    // Use BLoC to add lecture to game
    context.read<GamesBloc>().add(AddLectureToGameEvent(
          pdfUrl: lectureUploadLink!,
          gamePath: currentGame.id,
        ));

    // Reset lecture upload states
    setState(() {
      lectureUploadLink = null;
      lectureFileName = null;
      lectureUploadSuccess = false;
      _slideUpPanelValue = 0;
      toggleSlideUpPanel(0.0);
    });
  }

  // Method to handle the Add Lecture button press
  void onAddLecturePressed() async {
    if (_currentPage >= games.length) {
      return;
    }

    // Show a confirmation dialog before proceeding
    final bool confirmAddLecture = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Add Lecture'),
              content: Text(
                  'Adding a lecture will extend the current game with new content from a PDF file. Continue?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text('Continue'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmAddLecture) {
      await pickLectureFile();
    }
  }

  // Helper method to extract hash from game reference path
  String _extractHashFromPath(String path) {
    // Extract just the hash part after "/games/"
    if (path.contains('games/')) {
      return path.split('games/').last;
    }
    return path; // Return original if format is unexpected
  }

  // Add this conversion method
  List<GamesType> _convertToGamesType(List<GamesTypeEntity> entities) {
    return entities
        .map((entity) => GamesType(
              id: entity.id,
              author: entity.author,
              name: entity.name,
              description: entity.description,
              icon: entity.icon,
              gameList: entity.gameList,
              media: entity.media,
              playedHistory: entity.playedHistory,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GamesBloc, GamesState>(
      listener: (context, state) {
        if (state is UserGamesLoaded) {
          setState(() {
            games = state.games;
          });
        } else if (state is GameNameUpdated) {
          if (_currentPage < games.length) {
            setState(() {
              final updatedGame = games[_currentPage];
              games[_currentPage] = GamesTypeEntity(
                id: updatedGame.id,
                author: updatedGame.author,
                name: state.newName,
                description: updatedGame.description,
                icon: updatedGame.icon,
                gameList: updatedGame.gameList,
                media: updatedGame.media,
                playedHistory: updatedGame.playedHistory,
              );
              _isEditingTitle = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.gameTitleUpdated),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else if (state is GameIconUpdated) {
          if (_currentPage < games.length) {
            setState(() {
              final updatedGame = games[_currentPage];
              games[_currentPage] = GamesTypeEntity(
                id: updatedGame.id,
                author: updatedGame.author,
                name: updatedGame.name,
                description: updatedGame.description,
                icon: state.newIcon,
                gameList: updatedGame.gameList,
                media: updatedGame.media,
                playedHistory: updatedGame.playedHistory,
              );
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Game icon updated!'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else if (state is FileUploading) {
          setState(() {
            if (isLectureUploading) {
              lectureUploadProgress = state.progress;
            } else {
              progress = state.progress;
            }
          });
        } else if (state is FileUploaded) {
          setState(() {
            if (isLectureUploading) {
              lectureUploadLink = state.downloadUrl;
              lectureUploadSuccess = true;
              isLectureUploading = false;
              addLectureToExistingGame();
            } else {
              uploadLink = state.downloadUrl;
              uploadSuccess = true;
              isUploading = false;
            }
          });
        } else if (state is GameCreated) {
          _loadUserGames();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Game created successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is GameUpdated) {
          _loadUserGames();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Game updated successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is GameDeleted) {
          _loadUserGames();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Game deleted successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is GamesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentTheme, child) {
              final isDarkMode = currentTheme == ThemeMode.dark;

              // Show loading state
              if (state is GamesLoading && games.isEmpty) {
                return Scaffold(
                  backgroundColor: isDarkMode
                      ? AppColors.backgroundDarkmode
                      : AppColors.mainColor,
                  appBar: AppBar(
                    title: const Text(""),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              final bool canEditTitle = _isEditingTitle &&
                  (_currentPage < games.length || _currentPage == games.length);
              final bool showTitleEditor =
                  canEditTitle && _slideUpPanelValue >= slideValueThreshold;
              final bool showNormalTitle = !showTitleEditor;
              final Color titleColor = _slideUpPanelValue <= slideValueThreshold
                  ? AppColors.cardBackground
                  : Colors.white;

              // Get current user email for author check
              final String? currentUserEmail =
                  FirebaseAuth.instance.currentUser?.email;

              return Scaffold(
                backgroundColor: isDarkMode
                    ? AppColors.backgroundDarkmode
                    : AppColors.mainColor,
                appBar: AppBar(
                  title: const Text(""),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  actions: [
                    if (state is GamesLoading)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white)),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.refresh,
                            color: isDarkMode ? Colors.white : Colors.black),
                        onPressed: () {
                          if (_isEditingTitle) _saveTitleChanges();
                          _loadUserGames();
                          setState(() {
                            _currentPage = 0;
                            _slideUpPanelValue = 0;
                            toggleSlideUpPanel(0.0);
                          });
                        },
                        tooltip: 'Refresh Games',
                      ),
                  ],
                ),
                body: Stack(
                  children: [
                    PanelSlider(
                      games: _convertToGamesType(games),
                      currentPage: _currentPage,
                      slidePanelFunction: toggleSlideUpPanel,
                      isUploading: isUploading,
                      uploadProgress: progress,
                      fileName: fileName,
                      panelController: _panelController,
                      gameName: _currentPage < games.length && games.isNotEmpty
                          ? games[_currentPage].name
                          : _newGameTitle,
                      uploadSuccess: uploadSuccess,
                      onCreateGamePressed: onCreateGamePressed,
                      onReVersionPressed: onReVersionPressed,
                      onAddLecturePressed: onAddLecturePressed,
                      isCurrentUserAuthor:
                          _currentPage < games.length && games.isNotEmpty
                              ? games[_currentPage].author == currentUserEmail
                              : true, // Default to true for new games
                    ),
                    Column(
                      children: <Widget>[
                        const ProfileContainer(),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: () {
                            if (!_isEditingTitle &&
                                (_currentPage < games.length ||
                                    _currentPage == games.length) &&
                                _slideUpPanelValue >= slideValueThreshold) {
                              setState(() {
                                _isEditingTitle = true;
                                if (_currentPage < games.length) {
                                  _titleEditController.text =
                                      games[_currentPage].name;
                                } else {
                                  _titleEditController.text =
                                      _newGameTitle; // Use stored title
                                }
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
                                          maxLength: 20,
                                          buildCounter: (context,
                                                  {required currentLength,
                                                  required isFocused,
                                                  maxLength}) =>
                                              currentLength > 12
                                                  ? Text(
                                                      '$currentLength/$maxLength',
                                                      style: TextStyle(
                                                        color: currentLength >=
                                                                20
                                                            ? Colors.red
                                                            : Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  : null,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                            border: InputBorder.none,
                                            hintText: "Enter new title",
                                            hintStyle: TextStyle(
                                              color:
                                                  titleColor.withOpacity(0.5),
                                              fontSize: 25,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          onSubmitted: (newTitle) async {
                                            if (newTitle.trim().isNotEmpty) {
                                              await _saveTitleChanges();
                                            }
                                          },
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if ((_currentPage < games.length ||
                                                    _currentPage ==
                                                        games.length) &&
                                                _slideUpPanelValue >=
                                                    slideValueThreshold &&
                                                !_isEditingTitle)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4.0),
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                  color: titleColor,
                                                ),
                                              ),
                                            Text(
                                              showNormalTitle &&
                                                      _currentPage <
                                                          games.length
                                                  ? games[_currentPage].name
                                                  : showNormalTitle &&
                                                          _currentPage ==
                                                              games.length &&
                                                          _slideUpPanelValue >
                                                              slideValueThreshold
                                                      ? _newGameTitle // Use our stored variable here
                                                      : "",
                                              style: TextStyle(
                                                color: isDarkMode
                                                    ? AppColors.textPrimary
                                                    : _slideUpPanelValue >
                                                            slideValueThreshold
                                                        ? Colors.white
                                                        : AppColors
                                                            .cardBackground,
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

                                  setState(() {
                                    _currentPage = index;
                                    _isEditingTitle = false;
                                    _titleEditController.clear();
                                  });
                                },
                                itemCount:
                                    games.isNotEmpty ? games.length + 1 : 1,
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
                            if (_slideUpPanelValue > slideValueThreshold &&
                                _currentPage < games.length &&
                                !_isEditingTitle)
                              Positioned.fill(
                                child: _buildOptionIcons(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        if (_currentPage < games.length &&
                            _slideUpPanelValue <= slideValueThreshold &&
                            games.isNotEmpty)
                          _buildPlayGameButton()
                      ],
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  Widget _buildGameCard(int index, bool isSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              child: Center(
                child: ClipOval(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: backgroundSize,
                    color: _slideUpPanelValue <= slideValueThreshold
                        ? (isDarkMode
                            ? AppColors.accentDarkmode
                            : Colors.grey.shade300)
                        : (isDarkMode
                            ? AppColors.accentDarkmode2
                            : Color(0xFF102247)),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: isSelected && _slideUpPanelValue > slideValueThreshold
                  ? _showIconSelectionModal
                  : null,
              child: SizedBox(
                child: Transform.scale(
                  scale: 1.08,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        games[index].icon,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/animations/map2.GIF',
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                      if (isSelected &&
                          _slideUpPanelValue > slideValueThreshold)
                        Positioned(
                          bottom: 70,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(context)!.changeIcon,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGameCard(bool isSelected) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          if (_slideUpPanelValue <= slideValueThreshold) {
            setState(() {
              _slideUpPanelValue = 1.0;
              _panelController.open();
              _isEditingTitle = true;
              _titleEditController.text = _newGameTitle;
              _gameNameTextController.text = _newGameTitle;
            });
          } else {
            if (_isEditingTitle) {
              _saveTitleChanges();
            }

            pickFile();
          }
        }
      },
      child: Transform.scale(
        scale: isSelected ? 1.2 : 0.85,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..translate(0.0, isSelected ? -2.0 : 12.0, isSelected ? 10.0 : 0.0),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle
              _slideUpPanelValue > slideValueThreshold
                  ? Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode
                            ? AppColors.accentDarkmode2
                            : const Color(0xFF102247),
                        border: Border.all(
                          color: isDarkMode
                              ? AppColors.white
                              : const Color.fromARGB(255, 189, 197, 255),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 90,
                              color: isDarkMode
                                  ? AppColors.white
                                  : const Color.fromARGB(255, 189, 197, 255),
                            ),
                            Text(
                              'Upload file',
                              style: TextStyle(
                                color: isDarkMode
                                    ? AppColors.white
                                    : const Color.fromARGB(255, 189, 197, 255),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SvgPicture.asset(
                      "assets/images/add-icon.svg",
                      fit: BoxFit.contain,
                      color: isDarkMode
                          ? AppColors.textPrimary
                          : AppColors.cardBackground,
                      colorBlendMode: BlendMode.srcIn,
                    ),
              const SizedBox(height: 16),
              // "or" text divider
              if (_slideUpPanelValue > slideValueThreshold)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Container(
                        height: 1,
                        color: isDarkMode
                            ? AppColors.white
                            : const Color.fromARGB(255, 189, 197, 255),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'or',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.white
                            : const Color.fromARGB(255, 189, 197, 255),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Container(
                        height: 1,
                        color: isDarkMode
                            ? AppColors.white
                            : const Color.fromARGB(255, 189, 197, 255),
                      ),
                    ),
                  ],
                ),
            ],
          ),
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
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ]),
            child: Center(
              child: IconButton(
                iconSize: 16,
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                tooltip: AppLocalizations.of(context)!.deletegame,
                onPressed: () async {
                  if (_currentPage < games.length) {
                    final bool confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  AppLocalizations.of(context)!.confirmDelete),
                              content: Text(
                                  '${AppLocalizations.of(context)!.areYouSuretodelete} "${games[_currentPage].name}"? ${AppLocalizations.of(context)!.cannotbeundone}'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;

                    if (confirmDelete) {
                      try {
                        final User? user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User not authenticated')),
                          );
                          return;
                        }

                        int deletedPageIndex = _currentPage;
                        int newPageIndex =
                            _currentPage > 0 ? _currentPage - 1 : 0;

                        setState(() {
                          _slideUpPanelValue = 0;
                          toggleSlideUpPanel(0.0);
                        });

                        // Delete game using BLoC
                        context.read<GamesBloc>().add(DeleteGameEvent(
                              games[_currentPage].id,
                              user.email!,
                            ));

                        // Animate to new page
                        if (games.length > 1) {
                          _pageController.animateToPage(newPageIndex,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      } catch (e) {
                        print("Error deleting game: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error deleting game: $e'),
                              duration: Duration(seconds: 2)),
                        );
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
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ]),
            child: Center(
              child: IconButton(
                iconSize: 16,
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                tooltip: 'Share Game',
                onPressed: () {
                  if (_currentPage < games.length) {
                    // Get just the hash part
                    String gameHash =
                        _extractHashFromPath(games[_currentPage].id);

                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Share Game",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                "Share this game code with others:",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF102247),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        gameHash,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Monospace',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.copy, color: Colors.white),
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: gameHash));
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Game code copied to clipboard!'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Close",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.share),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayGameButton() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            if (_isEditingTitle) _saveTitleChanges();
            if (_currentPage < games.length) {
              context.push(Routes.playGamePage, extra: {
                'games': games[_currentPage].gameList,
                'reference': games[_currentPage].id,
                'gameName': games[_currentPage].name
              });
            } else {
              print(
                  "Error: Tried to play game with invalid index $_currentPage");
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDarkMode ? Colors.yellow[700] : AppColors.neutralBackground,
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
              Text(
                AppLocalizations.of(context)!.playGame,
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
