import 'package:flutter/material.dart';

class CamcodeOverlayPaint extends StatelessWidget {
  CamcodeOverlayPaint({
    Key? key,
    this.width = 400,
    this.height = -1,
    this.overlayColor = Colors.black,
  }) : super(key: key) {
    if (height < 0) {
      height = width * 0.6;
    }
  }

  final Color overlayColor;
  final double width;
  late double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        width,
        height,
      ),
      painter: _RPSCustomPainter(
        overlayColor: overlayColor,
      ),
    );
  }
}

class _RPSCustomPainter extends CustomPainter {
  final Color overlayColor;

  _RPSCustomPainter({
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint_0 = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.03;

    final path_0 = Path();
    path_0.moveTo(size.width * 0.1920286, size.height * 0.0137500);
    path_0.lineTo(size.width * 0.0078000, size.height * 0.0121500);
    path_0.lineTo(size.width * 0.0077429, size.height * 0.3374500);

    canvas.drawPath(path_0, paint_0);

    final paint_1 = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.03;

    final path_1 = Path();
    path_1.moveTo(size.width * 0.9879143, size.height * 0.6623500);
    path_1.lineTo(size.width * 0.9885714, size.height * 0.9800000);
    path_1.lineTo(size.width * 0.8041143, size.height * 0.9811500);

    canvas.drawPath(path_1, paint_1);

    final paint_2 = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.03;

    final path_2 = Path();
    path_2.moveTo(size.width * 0.1907429, size.height * 0.9818000);
    path_2.lineTo(size.width * 0.0085714, size.height * 0.9800000);
    path_2.lineTo(size.width * 0.0085714, size.height * 0.6650000);

    canvas.drawPath(path_2, paint_2);

    final paint_3 = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.03;

    final path_3 = Path();
    path_3.moveTo(size.width * 0.8091143, size.height * 0.0086500);
    path_3.lineTo(size.width * 0.9887143, size.height * 0.0087000);
    path_3.lineTo(size.width * 0.9878000, size.height * 0.3380000);

    canvas.drawPath(path_3, paint_3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return overlayColor != (oldDelegate as _RPSCustomPainter).overlayColor;
  }
}
