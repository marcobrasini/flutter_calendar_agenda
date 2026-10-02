import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'config.dart';
import 'enums.dart';


extension CalendarDimensions on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  CalendarConfig get config => CalendarConfig.of(this);

  TextStyle _style(TextStyle? style) =>
      DefaultTextStyle.of(this).style.merge(style);

  Size _measure(String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: _style(style)),
      textScaler: MediaQuery.textScalerOf(this),
      textDirection: Directionality.of(this),
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  }

  double tileHeight() {
    final eventConfig = config.event;
    final height = _measure("", eventConfig.textStyle).height;
    return height * 1.25 + (eventConfig.eventMargin + eventConfig.eventPadding) * 2;
  }


  double timeMargin() {
    final timeConfig = config.timeConfig();
    final style = _style(timeConfig.textStyle);
    final fontSize = MediaQuery.textScalerOf(this).scale(style.fontSize ?? 14.0);
    return fontSize * (style.height ?? 1.5);
  }


  double timeOffset() {
    final timeConfig = config.timeConfig();
    final width = _measure("All day", timeConfig.textStyle).width;
    return width + timeConfig.textPadding * 2;
  }


  double dateMargin() {
    return 0.0;
  }

  double dateOffset(CalendarView view) {
    final dateConfig = config.dateConfig(view);
    final text = Date.now().format(dateConfig.textFormat);
    final height = _measure(text, dateConfig.textStyle).height;
    return height + dateConfig.textPadding * 2;
  }
}