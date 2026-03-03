import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints an expanding circular ring around the button during the charge-up phase.
class ChargeRingPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  final double baseRadius;
  final double maxExpand;

  ChargeRingPainter({
    required this.progress,
    required this.color,
    this.baseRadius = 34.0,
    this.maxExpand = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = baseRadius + (maxExpand * progress);

    // Stroke width grows slightly as it charges
    final strokeWidth = 2.0 + (1.5 * progress);

    // Opacity ramps up then holds
    final opacity = (progress * 1.2).clamp(0.0, 0.8);

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw a sweep arc proportional to progress (full circle at 1.0)
    final sweepAngle = 2 * math.pi * progress;
    const startAngle = -math.pi / 2; // Start from top

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Add a subtle glow effect behind the arc
    if (progress > 0.2) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ChargeRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
