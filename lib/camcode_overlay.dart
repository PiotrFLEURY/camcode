import 'package:flutter/material.dart';

class CamcodeOverlay extends StatelessWidget {
  CamcodeOverlay({
    Key? key,
    this.width = 400,
    this.height = -1,
    this.overlayColor = Colors.black,
    this.animationDuration = -1,
  }) : super(key: key) {
    if (height < 0) {
      height = width * 0.6;
    }
  }

  final Color overlayColor;
  final double width;
  final int animationDuration;
  late double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size(
            width,
            height,
          ),
          painter: _RPSCustomPainter(
            overlayColor: overlayColor,
          ),
        ),
        if (animationDuration > 0)
          _AnimatedScannerBar(
            color: overlayColor,
            maxWidth: width,
            maxHeight: height,
            animationDuration: animationDuration,
          ),
      ],
    );
  }
}

class _AnimatedScannerBar extends StatefulWidget {
  _AnimatedScannerBar({
    Key? key,
    required this.color,
    required this.maxWidth,
    required this.maxHeight,
    this.animationDuration = 800,
  }) : super(key: key);

  final Color color;
  final double maxWidth;
  final double maxHeight;
  final int animationDuration;

  @override
  __AnimatedScannerBarState createState() => __AnimatedScannerBarState();
}

class __AnimatedScannerBarState extends State<_AnimatedScannerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController positionController;
  late Animation<double> positionAnimation;

  @override
  void dispose() {
    positionController.stop();
    positionController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _setupHeightAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: positionController,
      child: Container(
        height: 2,
        color: widget.color,
        width: widget.maxWidth,
      ),
      builder: (context, child) {
        return Positioned(
          child: child!,
          top: positionAnimation.value,
        );
      },
    );
  }

  void _setupHeightAnimation() {
    positionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration * 2),
    );
    positionAnimation = Tween<double>(
      begin: 0,
      end: widget.maxHeight,
    ).animate(positionController);
    positionController.repeat(reverse: true);
  }
}

class _RPSCustomPainter extends CustomPainter {
  final Color overlayColor;

  _RPSCustomPainter({
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final upperLeftPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.03;

    final upperLeftPath = Path()
      ..moveTo(size.width * 0.1920286, size.height * 0.0137500)
      ..lineTo(size.width * 0.0078000, size.height * 0.0121500)
      ..lineTo(size.width * 0.0077429, size.height * 0.3374500);

    canvas.drawPath(upperLeftPath, upperLeftPaint);

    final upperRightPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.03;

    final upperRightPath = Path()
      ..moveTo(size.width * 0.9879143, size.height * 0.6623500)
      ..lineTo(size.width * 0.9885714, size.height * 0.9800000)
      ..lineTo(size.width * 0.8041143, size.height * 0.9811500);

    canvas.drawPath(upperRightPath, upperRightPaint);

    final lowerRightPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.03;

    final lowerRightPath = Path()
      ..moveTo(size.width * 0.1907429, size.height * 0.9818000)
      ..lineTo(size.width * 0.0085714, size.height * 0.9800000)
      ..lineTo(size.width * 0.0085714, size.height * 0.6650000);

    canvas.drawPath(lowerRightPath, lowerRightPaint);

    final lowerLeftPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.03;

    final lowerLeftPath = Path()
      ..moveTo(size.width * 0.8091143, size.height * 0.0086500)
      ..lineTo(size.width * 0.9887143, size.height * 0.0087000)
      ..lineTo(size.width * 0.9878000, size.height * 0.3380000);

    canvas.drawPath(lowerLeftPath, lowerLeftPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final shouldRepaint =
        overlayColor != (oldDelegate as _RPSCustomPainter).overlayColor;

    return shouldRepaint;
  }
}
