import 'dart:math';
import 'package:flutter/material.dart';

class VinylPainter extends CustomPainter {
  final double progressFraction;
  final Color accentColor;
  final bool isPlaying;

  const VinylPainter({
    required this.progressFraction,
    required this.accentColor,
    this.isPlaying = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer vinyl disc
    final discPaint = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(center, radius, discPaint);

    // Groove rings
    final groovePaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= 8; i++) {
      canvas.drawCircle(center, radius * (0.95 - i * 0.06), groovePaint);
    }

    // Progress arc
    final arcRect =
        Rect.fromCircle(center: center, radius: radius * 0.88);
    final arcPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      arcRect,
      -pi / 2,
      2 * pi * progressFraction,
      false,
      arcPaint,
    );

    // Label center
    final labelPaint = Paint()..color = const Color(0xFF2D2D2D);
    canvas.drawCircle(center, radius * 0.28, labelPaint);

    // Center hole
    final holePaint = Paint()..color = const Color(0xFF0D0D0D);
    canvas.drawCircle(center, radius * 0.04, holePaint);

    // Spinning indicator dot (rotates with progress)
    if (isPlaying) {
      final angle = 2 * pi * progressFraction - pi / 2;
      final dotPos = Offset(
        center.dx + radius * 0.88 * cos(angle),
        center.dy + radius * 0.88 * sin(angle),
      );
      final dotPaint = Paint()..color = accentColor;
      canvas.drawCircle(dotPos, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(VinylPainter old) =>
      old.progressFraction != progressFraction || old.isPlaying != isPlaying;
}
