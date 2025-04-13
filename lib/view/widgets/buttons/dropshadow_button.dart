import 'package:flutter/material.dart';

class DropShadowButton extends StatelessWidget {
  final VoidCallback onPressed;

  final double width;
  final double height;

  final Color backgroundColor;
  final Color shadowColor;
  // Child widget for custom content.
  final Widget child;

  const DropShadowButton({
    super.key,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.child,
    this.backgroundColor = Colors.grey,
    this.shadowColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    // Use Inkwell for custom button behavior.
    return InkWell(
      onTap: onPressed,
      child: Stack(
        children: [
          // Shadow
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: shadowColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Main button
          Container(
            width: width,
            height: height - 8,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: child)
          ),
        ],
      ),
    );
  }
}
