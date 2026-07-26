import 'package:flutter/material.dart';
import '../tools/painter_string.dart';


class SlotString extends StatelessWidget {
  final String string;
  final double width;
  final TextStyle? textStyle;
  final int? maxLines;

  const SlotString({
    super.key,
    required this.string,
    required this.width,
    this.textStyle,
    this.maxLines,
  });

  StringPainter get painter => StringPainter(
    string: string,
    width: width,
    textStyle: textStyle,
    maxLines: maxLines,
  );

  double get height => painter.height;
  Rect get layout => Rect.fromLTWH(0.0, 0.0, width, height);

  @override
  Widget build(BuildContext context) {
    return SizedBox (
      width: width,
      height: height,
      child: CustomPaint(
        painter: painter,
      ),
    );
  }
}
