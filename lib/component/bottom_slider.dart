import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Add this import

class BottomSlider extends StatefulWidget {
  // final Widget child;
  final bool isVisible;
  final bool isTransitioning;
  final double height;
  final Map<String, dynamic> data;
  final double expandedHeight;

  const BottomSlider({
    super.key,
    // required this.child,
    required this.isVisible,
    required this.data,
    this.isTransitioning = false,
    this.height = 0.18,
    this.expandedHeight = 0.56, // Add this new parameter
  });

  @override
  State<BottomSlider> createState() => _BottomSliderState();
}

class _BottomSliderState extends State<BottomSlider>
    with TickerProviderStateMixin {
  // Changed from SingleTickerProviderStateMixin
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late bool _isCorrect = false;
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late AnimationController _textBoxController;
  late Animation<double> _textBoxAnimation;
  bool _isLoading = false;
  String? _explanation;

  @override
  void initState() {
    super.initState();

    // Slide animation setup
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Expand animation setup
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = Tween<double>(
      begin: widget.height,
      end: widget.expandedHeight,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    // Text box animation setup
    _textBoxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _textBoxAnimation = CurvedAnimation(
      parent: _textBoxController,
      curve: Curves.easeOut,
    );
  }

  Future<void> _fetchExplanation() async {
    if (widget.data['explanation'] != null) {
      setState(() {
        _explanation = widget.data['explanation'];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prompt =
          "Why this '${widget.data['correctAnswer']}' is a correct answer of this question '${widget.data['question']}' please do a short explanation.";

      final httpClient = http.Client();
      final response = await httpClient
          .get(Uri.https('monsh.xyz', '/explain_answer', {'context': prompt}));

      // Decode the response and extract data
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        _explanation = decodedResponse['data'] ?? 'No explanation available';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _explanation = 'Failed to load explanation';
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(BottomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    // print(widget.isTransitioning);
    if (!widget.isTransitioning) {
      setState(() {
        _isCorrect = widget.data['isCorrect'];
      });
    }


    // Don't animate during transitions
    if (!widget.isTransitioning) {
      if (widget.isVisible != oldWidget.isVisible) {
        if (widget.isVisible) {
          _slideController.forward();
          _fetchExplanation();
        }
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _expandController.dispose();
    _textBoxController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
        _textBoxController.forward();
      } else {
        _expandController.reverse();
        _textBoxController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: screenHeight * _expandAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: _isCorrect
                    ? const Color(0xFFBFD4FF)
                    : const Color(0xFFFFBDBE),
              ),
              child: SafeArea(
                top: true,
                child: Column(
                  children: [
                    // Header section
                    Container(
                      padding:
                          const EdgeInsets.only(left: 24, right: 24, top: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        _isCorrect ? Colors.blue : Colors.red,
                                    size: 36,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isCorrect ? "Correct!" : "Wrong!",
                                    style: TextStyle(
                                      color:
                                          _isCorrect ? Colors.blue : Colors.red,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                  size: 30,
                                ),
                                onPressed: _toggleExpand,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_isExpanded)
                      Expanded(
                        child: FadeTransition(
                          opacity: _textBoxAnimation,
                          child: SizeTransition(
                            sizeFactor: _textBoxAnimation,
                            child: Center(
                              // Added Center widget
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    0.86, // Adjusted width
                                // margin: const EdgeInsets.symmetric(vertical: 16),  // Changed margin
                                margin:
                                    const EdgeInsets.only(top: 14, bottom: 110),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                  color: _isCorrect
                                      ? const Color(0xFF89B2FF)
                                      : const Color(0xFFFF8688),
                                ),
                                child: _isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                            color: _isCorrect
                                                ? Color(0xFFBFD4FF)
                                                : Color(0xFFFFBDBE)),
                                      )
                                    : SingleChildScrollView(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          _explanation ??
                                              'No explanation available',
                                          style: TextStyle(
                                            // Bolded the text
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: _isCorrect
                                                ? const Color(0xFF103680)
                                                : const Color(0xFFB72222),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
