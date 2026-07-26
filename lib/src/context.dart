import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'utils/datetime.dart';


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
    final dateConfig = config.date;
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