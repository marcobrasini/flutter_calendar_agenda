import 'package:flutter/material.dart';
import '../../enums.dart';


/// Paints 24 hour lines.
class LinesPainter extends CustomPainter {
  final List<double> positions;
  final LineStyle lineStyle;
  final double lineWidth;
  final Color lineColor;
  final double offset;
  final double? length;
  final double? dashedWidth;
  final double? dashedSpace;
  final LineDirection direction;
  bool get isVertical => direction == LineDirection.vertical;
  bool get isHorizontal => direction == LineDirection.horizontal;

  LinesPainter({
    this.lineStyle = LineStyle.solid,
    required this.positions,
    required this.lineColor,
    required this.lineWidth,
    required this.direction,
    this.offset = 0.0,
    this.length,
    this.dashedWidth,
    this.dashedSpace,
  });


  void paintSolid(
      Paint paint,
      Canvas canvas,
      Size size,
      double fix,
      double beg,
      double end
  ) {
    (isHorizontal)
        ? canvas.drawLine(Offset(beg, fix), Offset(end, fix), paint)
        : canvas.drawLine(Offset(fix, beg), Offset(fix, end), paint);
  }

  void paintDashed(
      Paint paint,
      Canvas canvas,
      Size size,
      double fix,
      double beg,
      double end
  ) {
    var p = beg;
    while (p < end) {
      (isHorizontal)
          ? canvas.drawLine(Offset(p, fix), Offset(p + dashedWidth!, fix), paint)
          : canvas.drawLine(Offset(fix, p), Offset(fix, p + dashedWidth!), paint);
      p += dashedWidth! + dashedSpace!;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = lineWidth
      ..color = lineColor;
    final beg = offset;
    final end = beg + (length ?? ((isHorizontal) ? size.width : size.height) - beg);
    for (var fix in positions) {
      switch (lineStyle) {
        case LineStyle.solid:
          paintSolid(paint, canvas, size, fix, beg, end);
          break;
        case LineStyle.dashed:
          paintDashed(paint, canvas, size, fix, beg, end);
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is LinesPainter && (
        positions != oldDelegate.positions ||
        lineStyle != oldDelegate.lineStyle ||
        lineWidth != oldDelegate.lineWidth ||
        lineColor != oldDelegate.lineColor ||
        direction != oldDelegate.direction ||
        offset != oldDelegate.offset
    );
  }
}