import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandText extends StatelessWidget {
  const BrandText({
    super.key,
    required this.opacity,
    required this.slide,
  });

  final Animation<double> opacity;
  final Animation<Offset> slide;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: SvgPicture.asset(
          'assets/logo/brand_text.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
