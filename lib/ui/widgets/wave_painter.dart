import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;

  WavePainter({required this.animationValue, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = waveColor.withValues(alpha: 1.0 - animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final maxRadius = size.width / 1.5;
    final currentRadius = maxRadius * animationValue;

    canvas.drawCircle(center, currentRadius, paint);

    // Draw a second inner wave
    if (animationValue > 0.3) {
      final innerRadius = maxRadius * (animationValue - 0.3);
      final innerPaint = Paint()
        ..color = waveColor.withValues(
          alpha: (1.0 - animationValue + 0.3).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, innerRadius, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.waveColor != waveColor;
  }
}
