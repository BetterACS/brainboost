import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';

class CircularChartPainter extends CustomPainter {
  final double percentage;

  CircularChartPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 30;
    final double radius = size.width / 2 - strokeWidth / 2;

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final Paint backgroundPaint = Paint()
      ..color = const Color(0xFFC2C2C2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint foregroundPaint = Paint()
      ..shader = AppColors.circleGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      backgroundPaint,
    );

    double sweepAngle = 2 * pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: radius,
      ),
      0,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
