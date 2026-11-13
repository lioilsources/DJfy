import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The record on the platter. [angle] turns it (33⅓ rpm while playing, with
/// the finger while scratching); the progress arc and the light sheen stay put.
class VinylPainter extends CustomPainter {
  final double progressFraction;
  final Color accentColor;
  final ValueListenable<double> angle;

  VinylPainter({
    required this.progressFraction,
    required this.accentColor,
    required this.angle,
  }) : super(repaint: angle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer vinyl disc
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A1A1A));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle.value);

    // Groove rings, with a few brighter arcs so the rotation shows
    final groovePaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final shinePaint = Paint()
      ..color = Colors.white.withAlpha(45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 1; i <= 8; i++) {
      final r = radius * (0.95 - i * 0.06);
      canvas.drawCircle(Offset.zero, r, groovePaint);
      final rect = Rect.fromCircle(center: Offset.zero, radius: r);
      canvas.drawArc(rect, i * 0.7, 0.35, false, shinePaint);
    }

    // Label with a stripe, like a sticker you can follow while scratching
    canvas.drawCircle(Offset.zero, radius * 0.28, Paint()..color = const Color(0xFF2D2D2D));
    canvas.drawLine(
      Offset(0, -radius * 0.28),
      Offset(0, -radius * 0.93),
      Paint()
        ..color = accentColor.withAlpha(160)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // Static light reflection
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.7),
      -pi * 0.85,
      pi * 0.25,
      false,
      Paint()
        ..color = Colors.white.withAlpha(14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.35,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.88),
      -pi / 2,
      2 * pi * progressFraction,
      false,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Center hole
    canvas.drawCircle(center, radius * 0.04, Paint()..color = const Color(0xFF0D0D0D));
  }

  @override
  bool shouldRepaint(VinylPainter old) =>
      old.progressFraction != progressFraction || old.accentColor != accentColor || old.angle != angle;
}
