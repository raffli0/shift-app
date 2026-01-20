import 'package:flutter/material.dart';

class FaceLivenessPainter extends CustomPainter {
  final bool waitingForNeutral;
  final bool isFaceInFrame;

  final double ovalWidth;
  final double ovalHeight;

  const FaceLivenessPainter({
    required this.waitingForNeutral,
    required this.isFaceInFrame,
    required this.ovalWidth,
    required this.ovalHeight,
  });

  Color getFrameColor() {
    if (waitingForNeutral) {
      return Colors.green;
    } else if (isFaceInFrame) {
      return Colors.white;
    } else {
      return Colors.red;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // Draw Stoke
    final strokePaint = Paint()
      ..color = getFrameColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawOval(ovalRect, strokePaint);
  }

  @override
  bool shouldRepaint(covariant FaceLivenessPainter oldDelegate) {
    return oldDelegate.waitingForNeutral != waitingForNeutral ||
        oldDelegate.isFaceInFrame != isFaceInFrame;
  }
}
