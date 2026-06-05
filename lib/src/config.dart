import 'package:flutter/material.dart';
import 'enums.dart';
import 'const.dart';


class TextConfig{

  const TextConfig({
    required this.format,
    this.padding = 0.0,
    this.textStyle,
    this.background,
  });

  final String format;
  final double padding;
  final TextStyle? textStyle;
  final Color? background;
}


class LineConfig{

  const LineConfig({
    this.style = lineFrameStyle,
    this.color = lineFrameColor,
    this.width = lineFrameWidth,
    this.offsetX = lineFrameOffsetX,
    this.offsetY = lineFrameOffsetY,
    this.length,
    this.dashedWidth,
    this.dashedSpace,
  });

  final LineStyle style;
  final Color color;
  final double width;
  final double offsetX;
  final double offsetY;
  final double? length;
  final double? dashedWidth;
  final double? dashedSpace;
}


class ViewConfig{
  const ViewConfig({
    this.showHeader = true,
    this.showCurrent = true,
    this.currentColor,
  });

  final bool showHeader;
  final bool showCurrent;
  final Color? currentColor;
}

class CalendarConfig extends InheritedWidget {
  const CalendarConfig({
    super.key,
    required super.child,
    required this.view,
    required this.line,
    required this.header,
    this.time,
    this.date,
    this.week,
  });

  final ViewConfig view;
  final LineConfig line;
  final TextConfig header;
  final TextConfig? time;
  final TextConfig? date;
  final TextConfig? week;

  static CalendarConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CalendarConfig>();
  }

  @override
  bool updateShouldNotify(CalendarConfig oldWidget) {
    return line != oldWidget.line
        || header != oldWidget.header
        || time != oldWidget.time
        || date != oldWidget.date
        || week != oldWidget.week;
  }
}