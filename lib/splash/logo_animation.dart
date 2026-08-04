import 'package:flutter/material.dart';

import 'animations.dart';
import 'logo_painter.dart';
import 'widgets/brand_text.dart';
import 'widgets/paper_corner.dart';
import 'widgets/paper_outline.dart';
import 'widgets/pen_nib.dart';

class LogoAnimation extends StatelessWidget {
  const LogoAnimation({
    super.key,
    required this.animations,
  });

  final SplashAnimations animations;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final isMobile = screen.shortestSide < 600;
    final logoWidth = isMobile
        ? screen.shortestSide.clamp(220.0, 330.0)
        : screen.shortestSide.clamp(280.0, 430.0);
    final markHeight = logoWidth * 0.78;
    final textHeight = logoWidth * 0.18;

    return ScaleTransition(
      scale: animations.logoScale,
      child: FadeTransition(
        opacity: animations.logoOpacity,
        child: ScaleTransition(
          scale: animations.finalScale,
          child: SizedBox(
            width: logoWidth,
            height: markHeight + textHeight + 44,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  width: logoWidth,
                  height: markHeight,
                  child: PaperOutline(progress: animations.outlineProgress),
                ),
                Positioned(
                  top: markHeight * 0.03,
                  right: logoWidth * 0.05,
                  width: logoWidth * 0.27,
                  height: logoWidth * 0.27,
                  child: PaperCorner(progress: animations.cornerProgress),
                ),
                Positioned(
                  left: logoWidth * 0.05,
                  top: markHeight * 0.48,
                  width: logoWidth * 0.52,
                  height: markHeight * 0.43,
                  child: PenNib(
                    opacity: animations.penOpacity,
                    slide: animations.penSlide,
                    rotation: animations.penRotation,
                    shine: animations.shine,
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: animations.inkProgress,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: InkFlourishPainter(
                            progress: animations.inkProgress.value,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: -logoWidth * 0.08,
                  right: -logoWidth * 0.08,
                  bottom: 0,
                  height: textHeight,
                  child: BrandText(
                    opacity: animations.textOpacity,
                    slide: animations.textSlide,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
