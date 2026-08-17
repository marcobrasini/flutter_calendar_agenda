import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'config.dart';


extension CalendarDimensions on BuildContext {

  CalendarConfig get config => CalendarConfig.of(this);

  double timeMargin() {
    final timeConfig = config.time;
    if (timeConfig == null) return 0.0;
    final s = timeConfig.textStyle ?? DefaultTextStyle.of(this).style;
    return s.fontSize! * (s.height ?? 1.5);
  }

  double timeOffset() {
    final timeConfig = config.time;
    if (timeConfig == null) return 0.0;
    final Time time = Time(0, 0);
    final layout = TextPainter(
      text: TextSpan(
          text: (timeConfig.format != null)
              ? time.format(timeConfig.format!)
              : time.toString(),
          style: timeConfig.textStyle ?? DefaultTextStyle.of(this).style
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.width + (timeConfig.padding ?? 0.0) * 2;
  }

  double dateMargin() {
    return 0.0;
  }

  double dateOffset() {
    final dateConfig = config.date;
    final date = Date.now();
    final layout = TextPainter(
      text: TextSpan(
          text: (dateConfig.format != null)
              ? date.format(dateConfig.format!)
              : date.toString(),
          style: dateConfig.textStyle ?? DefaultTextStyle.of(this).style
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.height + (dateConfig.padding ?? 0.0) * 2;
  }
}