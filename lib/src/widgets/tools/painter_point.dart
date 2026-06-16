import 'package:flutter/material.dart';


class PointPainter extends CustomPainter {
  const PointPainter({
    required this.offset,
    required this.radius,
    required this.color,
  });

  final Offset offset;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is PointPainter && (
        offset != oldDelegate.offset ||
            radius != oldDelegate.radius ||
            color != oldDelegate.color
    );
  }
}