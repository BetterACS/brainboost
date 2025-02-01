import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:brainboost/component/colors.dart';

class UploadFileScreen extends StatelessWidget {
  const UploadFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF5FF),
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        leadingWidth: 20, 
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.containerBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Align(
          alignment: Alignment.centerLeft, 
          child: Text(
            'Create game',
            style: TextStyle(
              color: AppColors.containerBackground,
              fontWeight: FontWeight.bold, 
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 22, //ขนาดวงกลมใหญ่
              backgroundColor: AppColors.neutralBackground, // ขอบสีขาว
              child: CircleAvatar(
                radius: 19, // ขนาดวงกลมรูปภาพ
                backgroundImage: AssetImage('assets/images/profile.jpg'),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.containerBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Upload your files',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'File should be .pdf',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Game name',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter your game name',
                            hintStyle: TextStyle(
                              color: AppColors.containerBackground.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 160,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return CustomPaint(
                                    painter: _DashedBorderPainter(
                                      color: AppColors.white.withOpacity(1.0),
                                      strokeWidth: 3.0,
                                      dashLength: 10, 
                                      gapLength: 6,
                                      radius: 16,
                                    ),
                                    size: Size(constraints.maxWidth, constraints.maxHeight),
                                  );
                                },
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.white.withOpacity(0.2),
                                        width: 2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.cloud_upload_outlined,
                                      color: AppColors.white,
                                      size: 48,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Center(
                                  child: SizedBox(
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.neutralBackground,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                      ),
                                      child: const Text(
                                        'Browse files',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:  FontWeight.bold, 
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFABABAB),
                            foregroundColor: const Color(0xFFE5E5E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    // Draw top line
    double x = 0;
    while (x < width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(min(x + dashLength, width), 0),
        paint,
      );
      x += dashLength + gapLength;
    }

    // Draw right line
    double y = 0;
    while (y < height) {
      canvas.drawLine(
        Offset(width, y),
        Offset(width, min(y + dashLength, height)),
        paint,
      );
      y += dashLength + gapLength;
    }

    // Draw bottom line
    x = width;
    while (x > 0) {
      canvas.drawLine(
        Offset(x, height),
        Offset(max(x - dashLength, 0), height),
        paint,
      );
      x -= dashLength + gapLength;
    }

    // Draw left line
    y = height;
    while (y > 0) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, max(y - dashLength, 0)),
        paint,
      );
      y -= dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.radius != radius;
  }

  double min(double a, double b) => a < b ? a : b;
  double max(double a, double b) => a > b ? a : b;
}