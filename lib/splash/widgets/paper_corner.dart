import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaperCorner extends StatelessWidget {
  const PaperCorner({
    super.key,
    required this.progress,
  });

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        return Opacity(
          opacity: progress.value.clamp(0, 1),
          child: Transform(
            alignment: Alignment.topLeft,
            transform: _cornerTransform(progress.value),
            child: child,
          ),
        );
      },
      child: SvgPicture.asset(
        'assets/logo/paper_corner.svg',
        fit: BoxFit.contain,
      ),
    );
  }

  Matrix4 _cornerTransform(double value) {
    final scale = 0.96 + (value * 0.04);
    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY((1 - value) * -0.7)
      ..scaleByDouble(scale, scale, scale, 1);
  }
}
