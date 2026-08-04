import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'shine_effect.dart';

class PenNib extends StatelessWidget {
  const PenNib({
    super.key,
    required this.opacity,
    required this.slide,
    required this.rotation,
    required this.shine,
  });

  final Animation<double> opacity;
  final Animation<Offset> slide;
  final Animation<double> rotation;
  final Animation<double> shine;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: RotationTransition(
          turns: rotation,
          child: AnimatedBuilder(
            animation: opacity,
            builder: (context, child) {
              final blur = (1 - opacity.value) * 2.2;
              return ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: child,
              );
            },
            child: ShineEffect(
              progress: shine,
              child: SvgPicture.asset(
                'assets/logo/pen_nib.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
