import 'package:flutter/material.dart';

class DropShadowButton extends StatelessWidget {
  final VoidCallback onPressed;

  final double width;
  final double height;

  final Color backgroundColor;
  final Color shadowColor;
  // Child widget for the button
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
    return InkWell(

      onTap: onPressed,
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: shadowColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
              width: width, // Explicit width matching the main button
              height: height - 8, // Explicit height matching the main button
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: child) // Center the child widget,
              ),
        ],
      ),
    );
  }
}
