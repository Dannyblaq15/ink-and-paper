import 'package:flutter/animation.dart';

class SplashAnimations {
  SplashAnimations(this.controller)
      : backgroundOpacity = CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 0.055, curve: Curves.easeOut),
        ),
        logoOpacity = CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 0.145, curve: Curves.easeOutCubic),
        ),
        logoScale = Tween<double>(begin: 0.85, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0, 0.145, curve: Curves.easeOutCubic),
          ),
        ),
        outlineProgress = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.145, 0.36, curve: Curves.easeInOutCubic),
        ),
        cornerProgress = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.36, 0.5, curve: Curves.easeOutBack),
        ),
        penSlide = Tween<Offset>(
          begin: const Offset(-0.18, 0.18),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.5, 0.68, curve: Curves.easeOutCubic),
          ),
        ),
        penRotation = Tween<double>(begin: -0.05, end: 0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.5, 0.68, curve: Curves.easeOutCubic),
          ),
        ),
        penOpacity = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.48, 0.62, curve: Curves.easeOut),
        ),
        inkProgress = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.64, 0.78, curve: Curves.easeOutCubic),
        ),
        textOpacity = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.68, 0.82, curve: Curves.easeOut),
        ),
        textSlide = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.68, 0.82, curve: Curves.easeOutCubic),
          ),
        ),
        shine = CurvedAnimation(
          parent: controller,
          curve: const Interval(0.79, 0.9, curve: Curves.easeInOut),
        ),
        finalScale = TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1, end: 1.03)
                .chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 45,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.03, end: 1)
                .chain(CurveTween(curve: Curves.easeOutCubic)),
            weight: 55,
          ),
        ]).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.9, 1),
          ),
        );

  final AnimationController controller;
  final Animation<double> backgroundOpacity;
  final Animation<double> logoOpacity;
  final Animation<double> logoScale;
  final Animation<double> outlineProgress;
  final Animation<double> cornerProgress;
  final Animation<Offset> penSlide;
  final Animation<double> penRotation;
  final Animation<double> penOpacity;
  final Animation<double> inkProgress;
  final Animation<double> textOpacity;
  final Animation<Offset> textSlide;
  final Animation<double> shine;
  final Animation<double> finalScale;
}
