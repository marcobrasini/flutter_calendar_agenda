import 'package:flutter/material.dart';
import 'utils/datetime.dart';


extension CalendarMetrics on BuildContext {
  double timeMargin(TextStyle? style) {
    final s = style ?? DefaultTextStyle.of(this).style;
    return s.fontSize! * (s.height ?? 1.5);
  }

  double timeWidth(String format, TextStyle? style, double? padding) {
    final layout = TextPainter(
      text: TextSpan(
          text: Time(0, 0).format(format),
          style: style ?? DefaultTextStyle.of(this).style
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.width + (padding ?? 0) * 2;
  }

  double dateWidth(String format, TextStyle? style, double? padding) {
    final layout = TextPainter(
      text: TextSpan(
          text: Date.now().format(format),
          style: style ?? DefaultTextStyle.of(this).style
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.height + (padding ?? 0) * 2;
  }
}