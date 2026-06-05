import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'utils/datetime.dart';


extension CalendarMetrics on BuildContext {
  double timeMargin() {
    final timeConfig = CalendarConfig.of(this)!.time;
    if (timeConfig == null) return 0.0;
    final s = timeConfig.textStyle ?? DefaultTextStyle.of(this).style;
    return s.fontSize! * (s.height ?? 1.5);
  }

  double timeOffset() {
    final timeConfig = CalendarConfig.of(this)!.time;
    if (timeConfig == null) return 0.0;
    final layout = TextPainter(
      text: TextSpan(
          text: Time(0, 0).format(timeConfig.format),
          style: timeConfig.textStyle ?? DefaultTextStyle.of(this).style
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.width + timeConfig.padding*2;
  }

  double dateMargin() {
    return 0.0;
  }

  double dateOffset() {
    final dateConfig = CalendarConfig.of(this)!.date;
    if (dateConfig == null) return 0.0;
    final layout = TextPainter(
      text: TextSpan(
          text: Date.now().format(dateConfig.format),
          style: dateConfig.textStyle ?? DefaultTextStyle.of(this).style
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return layout.height + dateConfig.padding*2;
  }
}