import 'package:brainboost/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/services/user.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/component/avatar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PanelSlider extends StatefulWidget {
  final UserServices userServices = UserServices();
  final List<GamesType> games;
  final int currentPage;
  final void Function(double) slidePanelFunction;
  final bool isUploading;
  final double uploadProgress;
  final String? fileName;
  final PanelController? panelController;
  final String? gameName;
  final bool uploadSuccess;
  final VoidCallback? onCreateGamePressed;
  final VoidCallback? onImportSuccess;
  final VoidCallback? onReVersionPressed; // New callback for re-version
  final VoidCallback? onAddLecturePressed; // New callback for adding lecture
  final bool isCurrentUserAuthor; // New property to check if user is the author

  PanelSlider({
    Key? key,
    required this.games,
    required this.currentPage,
    required this.slidePanelFunction,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.fileName,
    this.panelController,
    this.gameName,
    this.uploadSuccess = false,
    this.onCreateGamePressed,
    this.onImportSuccess,
    this.onReVersionPressed, // Add this parameter
    this.onAddLecturePressed, // Add this parameter
    this.isCurrentUserAuthor = false, // Default to false for safety
  }) : super(key: key);

  @override
  State<PanelSlider> createState() => _PanelSliderState();
}

class _PanelSliderState extends State<PanelSlider> {
  late PanelController _panelController;
  final TextEditingController _importPathController = TextEditingController();
  bool _isImporting = false;
  String? _importError;

  // Add static cache for profile images
  static final Map<String, Widget> _profileCache = {};
  static const int _maxCacheSize = 100; // Limit cache size

  // Add cache cleanup method
  void _cleanupCache() {
    if (_profileCache.length > _maxCacheSize) {
      // Remove oldest 20% of entries when cache is full
      final entriesToRemove = (_maxCacheSize * 0.2).round();
      final keys = _profileCache.keys.toList();
      for (var i = 0; i < entriesToRemove && i < keys.length; i++) {
        _profileCache.remove(keys[i]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _panelController = widget.panelController ?? PanelController();
  }

  @override
  void dispose() {
    _importPathController.dispose();
    _cleanupCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isValidIndex =
        widget.games.isNotEmpty && widget.currentPage < widget.games.length;

    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentTheme, child) {
          final isDarkMode = currentTheme == ThemeMode.dark;
          
          // Define theme colors based on mode
          final Color panelBackgroundColor = isDarkMode 
              ? AppColors.accentDarkmode 
              : AppColors.cardBackground;
              
          final Color buttonBackgroundColor = isDarkMode
              ? Colors.white
              : Colors.white;
              
          final Color buttonForegroundColor = isDarkMode
              ? const Color.fromARGB(255, 52, 70, 105)
              : AppColors.buttonText;
              
          final Color buttonBorderColor = isDarkMode
              ? Colors.white
              : Colors.white;
              
          // disabled button for light and dark modes
          final Color disabledButtonBackgroundColor = isDarkMode
              ? Colors.grey.shade800  
              : Colors.grey.shade300; 
              
          final Color disabledButtonForegroundColor = isDarkMode
              ? Colors.grey.shade600 
              : Colors.grey.shade400; 
              
          final Color disabledButtonBorderColor = isDarkMode
              ? Colors.grey.shade800  
              : Colors.grey.shade300; 
          
          final Color playHistoryBackgroundColor = isDarkMode
              ? Color(0xFF1E293B) 
              : Color(0xFFECF5FF); 
              
          final Color playHistoryTextColor = isDarkMode
              ? Colors.white
              : Color(0xFF05235F);
              
          final Color playButtonBackgroundColor = isDarkMode
              ? Colors.yellow[700]!
              : AppColors.neutralBackground;
              
          final Color indicatorColor = Colors.white54;
          
          BorderRadiusGeometry radius = const BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
          );

          if (!isValidIndex) {
            return SlidingUpPanel(
              controller: _panelController,
              header: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 160,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ),
              onPanelSlide: (double value) => widget.slidePanelFunction(value),
              onPanelOpened: () => widget.slidePanelFunction(1.0),
              onPanelClosed: () => widget.slidePanelFunction(0.0),
              minHeight: 240,
              maxHeight: 780,
              borderRadius: radius,
              panel: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: panelBackgroundColor,
                  borderRadius: radius,
                ),
                child: _buildUploadingPanel(context),
              ),
              collapsed: Container(
                decoration: BoxDecoration(
                  color: panelBackgroundColor,
                  borderRadius: radius,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 4),
                      height: 4,
                      width: 160,
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      AppLocalizations.of(context)!.sideuptocreateanewgame,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SlidingUpPanel(
            controller: _panelController,
            header: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(top: 8),
                  height: 4,
                  width: 160,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    )
                  ),
                ),
              ),
            ),
            onPanelSlide: (double value) => widget.slidePanelFunction(value),
            onPanelOpened: () => widget.slidePanelFunction(1.0),
            onPanelClosed: () => widget.slidePanelFunction(0.0),
            minHeight: isValidIndex &&
                    widget.games[widget.currentPage].played_history.isEmpty
                ? 172
                : 240,
            maxHeight: 780,
            borderRadius: radius,
            panel: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: panelBackgroundColor,
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
                          onPressed: widget.isCurrentUserAuthor
                              ? widget.onReVersionPressed
                              : null,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: widget.isCurrentUserAuthor
                                ? buttonBackgroundColor
                                : disabledButtonBackgroundColor,
                            foregroundColor: widget.isCurrentUserAuthor
                                ? buttonForegroundColor
                                : disabledButtonForegroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                                color: widget.isCurrentUserAuthor
                                    ? buttonBorderColor
                                    : disabledButtonBorderColor,
                                width: 2),
                            minimumSize: const Size(160, 40),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.reversion,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: widget.isCurrentUserAuthor
                              ? widget.onAddLecturePressed
                              : null,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: widget.isCurrentUserAuthor
                                ? buttonBackgroundColor
                                : disabledButtonBackgroundColor,
                            foregroundColor: widget.isCurrentUserAuthor
                                ? buttonForegroundColor
                                : disabledButtonForegroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                                color: widget.isCurrentUserAuthor
                                    ? buttonBorderColor
                                    : disabledButtonBorderColor,
                                width: 2),
                            minimumSize: const Size(160, 40),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.addLecture,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 2, vertical: 14),
                        width: 340,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: playHistoryBackgroundColor,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget.games[widget.currentPage]
                                    .played_history.isEmpty
                                ? [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .noplayhistoryyet,
                                      style: TextStyle(
                                        color: playHistoryTextColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ]
                                : List.generate(
                                    widget.games[widget.currentPage]
                                        .played_history.length, (index) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      child: Column(
                                        children: [
                                          FutureBuilder<Widget>(
                                            future: buildUserIconForPanel(
                                                widget.games[widget.currentPage]
                                                        .played_history[index]
                                                    ['player'],
                                                40),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Icon(Icons.error,
                                                    size: 40,
                                                    color: Colors.red);
                                              } else {
                                                return snapshot.data!;
                                              }
                                            },
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            widget.games[widget.currentPage]
                                                .played_history[index]['score']
                                                .toString(),
                                            style: TextStyle(
                                              color: playHistoryTextColor,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 14),
                      width: 340,
                      height: 86,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.push(Routes.playGamePage, extra: {
                          'games': widget.games[widget.currentPage].gameList,
                          'reference': widget.games[widget.currentPage].ref
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: playButtonBackgroundColor,
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
                              colorFilter: ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.playgames,
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
                    color: indicatorColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    )
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: panelBackgroundColor,
                    borderRadius: radius,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        widget.games[widget.currentPage].played_history.isEmpty
                            ? AppLocalizations.of(context)!.noPlayHistory
                            : AppLocalizations.of(context)!.playedhistory,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          height: widget.games[widget.currentPage]
                                  .played_history.isEmpty
                              ? 0
                              : 20),
                      SizedBox(
                        height: 120,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.games[widget.currentPage].played_history
                                    .length,
                                (index) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      children: [
                                        FutureBuilder<Widget>(
                                          future: buildUserIconForPanel(
                                              widget.games[widget.currentPage]
                                                      .played_history[index]
                                                  ['player'],
                                              40),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return SizedBox(
                                                width: 40,
                                                height: 40,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Icon(Icons.error,
                                                  size: 40, color: Colors.red);
                                            } else {
                                              return snapshot.data!;
                                            }
                                          },
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          widget.games[widget.currentPage]
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
        });
  }

  Widget _buildUploadingPanel(BuildContext context) {
    final bool isButtonEnabled = widget.uploadSuccess &&
        widget.gameName != null &&
        widget.gameName!.isNotEmpty;

    final currentTheme = Theme.of(context).brightness;
    final bool isDarkMode = currentTheme == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 360),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showImportDialog(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.accentDarkmode
                          : Colors.blue.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.file_download_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.importGame,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Add PDF upload instruction box when no file is selected
        if (!widget.isUploading &&
            widget.uploadProgress <= 0 &&
            !widget.uploadSuccess)
          Container(
            margin: EdgeInsets.symmetric(vertical: 24, horizontal: 4),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.accentDarkmode2 : Color(0xFF152A56),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.uploadPDFfilecontinue,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.selectPdfDocument,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

        // Show progress if uploading
        if (widget.isUploading || widget.uploadSuccess)
          Container(
            margin: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF152A56),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.uploadSuccess
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.uploadSuccess
                            ? Icons.check_circle
                            : Icons.upload_file,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.uploadSuccess
                                ? AppLocalizations.of(context)!.uploadComplete
                                : AppLocalizations.of(context)!.uploadingFile,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.fileName != null)
                            Text(
                              widget.fileName!.length > 30
                                  ? widget.fileName!.substring(0, 30) + '...'
                                  : widget.fileName!,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    color: widget.uploadSuccess
                        ? Color(0xFF4CD964)
                        : Color(0xFF5AC8FA),
                    minHeight: 16,
                    value: widget.uploadSuccess ? 1.0 : widget.uploadProgress,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

        Spacer(),
        Container(
          margin: EdgeInsets.only(bottom: 120),
          width: MediaQuery.of(context).size.width * 0.8,
          height: 56,
          child: ElevatedButton(
            onPressed: isButtonEnabled ? widget.onCreateGamePressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled
                  ? AppColors.neutralBackground
                  : Colors.grey.shade700,
              disabledBackgroundColor: Colors.grey.shade400,
              disabledForegroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isButtonEnabled ? 4 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isButtonEnabled)
                  SvgPicture.asset(
                    'assets/images/game.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.createGame,
                  style: TextStyle(
                    color:
                        isButtonEnabled ? Colors.white : Colors.grey.shade600,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showImportDialog(BuildContext context) {
    _importPathController.clear();
    _importError = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.importGame,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _importPathController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.gamePath,
                        hintText: AppLocalizations.of(context)!.gamePathHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.link),
                        errorText: _importError,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.enterGamePathMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: _isImporting
                      ? null
                      : () async {
                          if (_importPathController.text.trim().isEmpty) {
                            setState(() {
                              _importError =
                                  AppLocalizations.of(context)!.gamePathEmpty;
                            });
                            return;
                          }

                          setState(() {
                            _isImporting = true;
                            _importError = null;
                          });

                          try {
                            final email =
                                widget.userServices.getCurrentUserEmail();
                            if (email != null) {
                              await widget.userServices.addSharedGame(
                                  email: email,
                                  gamePath: _importPathController.text.trim());

                              Navigator.of(context).pop();
                              if (widget.onImportSuccess != null) {
                                widget.onImportSuccess!();
                              }

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .gameImportedSuccess),
                                backgroundColor: Colors.green,
                              ));
                            } else {
                              throw Exception(AppLocalizations.of(context)!
                                  .usernotloggedin);
                            }
                          } catch (e) {
                            setState(() {
                              _importError = e.toString();
                              _isImporting = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutralBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isImporting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ))
                      : Text(
                          AppLocalizations.of(context)!.import,
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void openPanel() {
    _panelController.open();
  }

  void closePanel() {
    _panelController.close();
  }

  Future<Widget> buildUserIconForPanel(
      DocumentReference<Map<String, dynamic>> userEmail, double size) async {
    final String cacheKey = '${userEmail.path}_$size';

    // Return cached version if available
    if (_profileCache.containsKey(cacheKey)) {
      return _profileCache[cacheKey]!;
    }

    FirebaseStorage storage = FirebaseStorage.instance;
    String? path = await UserServices().getUserIcon(email: userEmail.path);

    Widget avatar;
    if (path == null) {
      avatar = UserAvatar(
        imageUrl: 'assets/images/profile.png',
        width: size,
      );
    } else {
      try {
        final ref = storage.ref().child(path);
        final url = await ref.getDownloadURL();
        avatar = UserAvatar(
          imageUrl: url,
          width: size,
        );
      } catch (e) {
        avatar = UserAvatar(
          imageUrl: 'assets/images/profile.png',
          width: size,
        );
      }
    }

    // Store in cache
    _profileCache[cacheKey] = avatar;
    _cleanupCache();

    return avatar;
  }
}
