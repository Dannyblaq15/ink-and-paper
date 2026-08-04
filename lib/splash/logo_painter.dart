import 'package:flutter/material.dart';

class PaperOutlinePainter extends CustomPainter {
  const PaperOutlinePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.06)
      ..lineTo(size.width * 0.67, size.height * 0.06)
      ..lineTo(size.width * 0.90, size.height * 0.34)
      ..lineTo(size.width * 0.90, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.90,
        size.height * 0.93,
        size.width * 0.75,
        size.height * 0.93,
      )
      ..lineTo(size.width * 0.18, size.height * 0.93)
      ..quadraticBezierTo(
        size.width * 0.04,
        size.height * 0.93,
        size.width * 0.04,
        size.height * 0.76,
      )
      ..lineTo(size.width * 0.04, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.04,
        size.height * 0.06,
        size.width * 0.18,
        size.height * 0.06,
      );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress.clamp(0, 1)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PaperOutlinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class InkFlourishPainter extends CustomPainter {
  const InkFlourishPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.34, size.height * 0.78)
      ..cubicTo(
        size.width * 0.40,
        size.height * 0.82,
        size.width * 0.47,
        size.height * 0.82,
        size.width * 0.53,
        size.height * 0.77,
      );
    final paint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.012
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress.clamp(0, 1)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant InkFlourishPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
