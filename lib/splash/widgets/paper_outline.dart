import 'package:flutter/material.dart';

import '../logo_painter.dart';

class PaperOutline extends StatelessWidget {
  const PaperOutline({
    super.key,
    required this.progress,
  });

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        return CustomPaint(
          painter: PaperOutlinePainter(
            progress: progress.value,
            color: Colors.black,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
