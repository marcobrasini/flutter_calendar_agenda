import 'package:flutter/material.dart';
import '../../enums.dart';
import 'painter_point.dart';


class LinesPainter extends CustomPainter {

  const LinesPainter({
    this.divisions = 0,
    this.positions = const <double>[],
    required this.lineStyle,
    required this.lineColor,
    required this.lineWidth,
    required this.direction,
    this.offset = Offset.zero,
    this.length,
    this.dashedWidth,
    this.dashedSpace,
    this.points,
  });

  final int divisions;
  final List<double> positions;
  final LineStyle lineStyle;
  final double lineWidth;
  final Color lineColor;
  final Offset offset;
  final double? length;
  final double? dashedWidth;
  final double? dashedSpace;
  final List<PointPainter>? points;
  final LineDirection direction;
  bool get isVertical => direction == LineDirection.vertical;
  bool get isHorizontal => direction == LineDirection.horizontal;

  double lineLength(Size size) =>
      length ?? ((isHorizontal) ? size.width : size.height);

  List<double> linePositions(Size size) {
    if (positions.isEmpty) {
      final range = (isHorizontal) ? size.height : size.width;
      final delta = (isHorizontal) ? offset.dy : offset.dx;
      final step = (range - delta) / divisions;
      return (delta == 0.0)
          ? [for (int i = 0; i <= divisions; i++) delta + i * step]
          : [for (int i = 0; i < divisions; i++) delta + i * step];
    }
    return positions;
  }

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
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final beg = 0.0;
    final end = beg + (lineLength(size) - beg);
    for (var fix in linePositions(size)) {
      switch (lineStyle) {
        case LineStyle.solid:
          paintSolid(paint, canvas, size, fix, beg, end);
          break;
        case LineStyle.dashed:
          paintDashed(paint, canvas, size, fix, beg, end);
          break;
      }
    }
    if (points != null) {
      for (PointPainter point in points!) {
        point.paint(canvas, size);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is LinesPainter && (
        divisions != oldDelegate.divisions ||
        positions != oldDelegate.positions ||
        lineStyle != oldDelegate.lineStyle ||
        lineWidth != oldDelegate.lineWidth ||
        lineColor != oldDelegate.lineColor ||
        direction != oldDelegate.direction ||
        offset != oldDelegate.offset
    );
  }
}