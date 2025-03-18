import 'package:flutter/material.dart';

class BottomSlider extends StatefulWidget {
  // final Widget child;
  final bool isVisible;
  final bool isTransitioning;
  final double height;
  final Map<String, dynamic> data;

  const BottomSlider({
    super.key,
    // required this.child,
    required this.isVisible,
    required this.data,
    this.isTransitioning = false,
    this.height = 0.21,
  });

  @override
  State<BottomSlider> createState() => _BottomSliderState();
}

class _BottomSliderState extends State<BottomSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late bool _isCorrect = false;

  @override
  void initState() {
    super.initState();

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
        }
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final bool isCorrect = widget.data['isCorrect'] ?? false;
    // final String message = isCorrect ? "Correct!" : "Wrong!";

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: screenHeight * widget.height,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color:
                _isCorrect ? const Color(0xFFBFD4FF) : const Color(0xFFFFBDBE),
          ),
          child: SafeArea(
            top: true,
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect ? Colors.blue : Colors.red,
                        size: 36,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCorrect ? "Correct!" : "Wrong!",
                        style: TextStyle(
                          color: _isCorrect ? Colors.blue : Colors.red,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
