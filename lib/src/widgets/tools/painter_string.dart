import 'package:flutter/material.dart';


class StringPainter extends CustomPainter {
  final String string;
  final double? width;
  final TextStyle? textStyle;
  final int? maxLines;

  const StringPainter({
    required this.string,
    this.width,
    this.textStyle,
    this.maxLines,
  });

  TextPainter get painter => TextPainter(
    text: TextSpan(
      text: string,
      style: textStyle,
    ),
    textDirection: TextDirection.ltr,
    maxLines: maxLines,
  )..layout(
    maxWidth: width ?? double.infinity,
  );

  double get height => painter.height;

  @override
  void paint(Canvas canvas, Size size) {
    painter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
