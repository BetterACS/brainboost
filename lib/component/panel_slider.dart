import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/services/user.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';

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
  }) : super(key: key);

  @override
  State<PanelSlider> createState() => _PanelSliderState();
}

class _PanelSliderState extends State<PanelSlider> {
  late PanelController _panelController;

  @override
  void initState() {
    super.initState();
    _panelController = widget.panelController ?? PanelController();
  }

  @override
  Widget build(BuildContext context) {
    final bool isValidIndex =
        widget.games.isNotEmpty && widget.currentPage < widget.games.length;

    BorderRadiusGeometry radius = BorderRadius.only(
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
                color: Colors.white54,
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
            color: AppColors.cardBackground,
            borderRadius: radius,
          ),
          child: _buildUploadingPanel(context),
        ),
        collapsed: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: radius,
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 8, bottom: 4),
                height: 4,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              SizedBox(height: 40),
                  Text(
                      "Slide up to create a new game",
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
                color: Colors.white54,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                )),
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
                      children: widget
                              .games[widget.currentPage].played_history.isEmpty
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
                              widget.games[widget.currentPage].played_history
                                  .length, (index) {
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
                                      widget.games[widget.currentPage]
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
                    'games': widget.games[widget.currentPage].gameList,
                    'reference': widget.games[widget.currentPage].ref
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
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                  widget.games[widget.currentPage].played_history.isEmpty
                      ? "No played history"
                      : "Played history",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                    height:
                        widget.games[widget.currentPage].played_history.isEmpty
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
                          widget
                              .games[widget.currentPage].played_history.length,
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
  }

  Widget _buildUploadingPanel(BuildContext context) {
    final bool isButtonEnabled = widget.uploadSuccess &&
        widget.gameName != null &&
        widget.gameName!.isNotEmpty;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 360),
        
        // Add PDF upload instruction box when no file is selected
        if (!widget.isUploading && widget.uploadProgress <= 0 && !widget.uploadSuccess)
          Container(
            margin: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF152A56),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Container(
                //   width: 80,
                //   height: 80,
                //   decoration: BoxDecoration(
                //     color: Colors.blue.shade700,
                //     shape: BoxShape.circle,
                //   ),
                //   child: Icon(
                //     Icons.picture_as_pdf_rounded,
                //     color: Colors.white,
                //     size: 40,
                //   ),
                // ),
                // SizedBox(height: 20),
                Text(
                  "Upload PDF file to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Select a PDF document to create your game",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
        // SizedBox(height: !widget.isUploading && widget.uploadProgress <= 0 && !widget.uploadSuccess ? 20 : 260),
        
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
                                ? "Upload Complete!"
                                : "Uploading File...",
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
            onPressed: isButtonEnabled
                ? widget.onCreateGamePressed
                : null,
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
                  'Create Game',
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

  void openPanel() {
    _panelController.open();
  }

  void closePanel() {
    _panelController.close();
  }
}
