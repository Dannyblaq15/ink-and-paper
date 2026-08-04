import 'package:flutter/material.dart';

class ShineEffect extends StatelessWidget {
  const ShineEffect({
    super.key,
    required this.progress,
    required this.child,
  });

  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, child) {
        final value = progress.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final sweep = -1.2 + (value * 2.4);
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.black,
                Color(0xff777777),
                Colors.black,
              ],
              stops: [
                (sweep - 0.12).clamp(0, 1),
                sweep.clamp(0, 1),
                (sweep + 0.12).clamp(0, 1),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}
