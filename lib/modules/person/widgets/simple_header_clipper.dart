import 'package:flutter/material.dart';

class SimpleHeaderClipper extends CustomClipper<Path> {
  static const double curveHeight = -20.0;
  static const double curveDepth = 160.0; // How much deeper the center dips

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - curveHeight);

    path.cubicTo(
      size.width * 0.25,
      size.height - curveHeight - curveDepth,
      size.width * 0.75,
      size.height - curveHeight - curveDepth,
      size.width,
      size.height - curveHeight,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(SimpleHeaderClipper old) => false;
}
