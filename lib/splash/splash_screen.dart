import 'package:flutter/material.dart';

import 'animations.dart';
import 'logo_animation.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.home,
  });

  final Widget home;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final SplashAnimations _animations;
  bool _showHome = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _animations = SplashAnimations(_controller);
    _controller.forward().whenComplete(() {
      if (mounted) {
        setState(() => _showHome = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showHome
          ? widget.home
          : Scaffold(
              key: const ValueKey('splash'),
              backgroundColor: Colors.transparent,
              body: FadeTransition(
                opacity: _animations.backgroundOpacity,
                child: ColoredBox(
                  color: AppTheme.burntOrange,
                  child: _SplashContent(animations: _animations),
                ),
              ),
            ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({required this.animations});

  final SplashAnimations animations;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RepaintBoundary(
        child: LogoAnimation(animations: animations),
      ),
    );
  }
}
