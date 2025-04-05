import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';

class CircularChartPainter extends CustomPainter {
  final double percentage;
  final bool isDarkMode; // เพิ่มตัวแปร isDarkMode

  CircularChartPainter(this.percentage, this.isDarkMode);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 30;
    final double radius = size.width / 2 - strokeWidth / 2;

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    // สีพื้นหลังของกราฟ
    final Paint backgroundPaint = Paint()
      ..color = isDarkMode
          ? AppColors.accentDarkmode // สีในโหมด Dark
          : const Color(0xFFC2C2C2) // สีในโหมด Light
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // สีของกราฟ
    final Paint foregroundPaint = Paint()
      ..shader = isDarkMode
          ? LinearGradient(
              colors: [AppColors.accentDarkmode, AppColors.textPrimary],
            ).createShader(rect) // สีในโหมด Dark
          : AppColors.circleGradient.createShader(rect) // สีในโหมด Light
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // วาดวงกลมพื้นหลัง
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      backgroundPaint,
    );

    // วาดกราฟ
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
