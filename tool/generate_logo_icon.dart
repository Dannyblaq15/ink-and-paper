import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final canvas = img.Image(width: size, height: size);
  final burntOrange = img.ColorRgb8(148, 68, 46);
  final white = img.ColorRgb8(255, 255, 255);

  img.fill(canvas, color: burntOrange);

  void line(int x1, int y1, int x2, int y2, {num thickness = 32}) {
    img.drawLine(
      canvas,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      color: white,
      thickness: thickness,
      antialias: false,
    );
  }

  void poly(List<Point<int>> points, {num thickness = 32}) {
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      line(a.x, a.y, b.x, b.y, thickness: thickness);
    }
  }

  // Document outline, centered and proportioned for app icons.
  line(286, 166, 604, 166, thickness: 34);
  line(286, 166, 286, 780, thickness: 34);
  line(286, 780, 704, 780, thickness: 34);
  line(704, 330, 704, 780, thickness: 34);
  line(604, 166, 704, 330, thickness: 34);
  line(604, 166, 604, 330, thickness: 34);
  line(604, 330, 704, 330, thickness: 34);

  // Fountain pen mark.
  poly([
    const Point(330, 642),
    const Point(398, 466),
    const Point(614, 394),
    const Point(540, 610),
  ], thickness: 34);
  line(398, 466, 540, 610, thickness: 28);
  line(614, 394, 470, 540, thickness: 28);
  img.fillCircle(canvas, x: 470, y: 540, radius: 24, color: white);
  img.fillCircle(canvas, x: 470, y: 540, radius: 9, color: burntOrange);
  poly([
    const Point(330, 642),
    const Point(260, 712),
    const Point(336, 788),
    const Point(398, 642),
  ], thickness: 32);

  File('assets/logo/ink_paper_icon.png')
      .writeAsBytesSync(img.encodePng(canvas));
}
