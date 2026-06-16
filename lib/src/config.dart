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
    this.swipeDirection = Axis.horizontal,
    this.showHeader = true,
    this.showIndicator = true,
    this.indicatorPeriod = timeIndicatorPeriod,
    this.indicatorRadius = timeIndicatorPointRadius,
    this.indicatorWidth = timeIndicatorLineWidth,
    this.indicatorColor,
  });

  final Axis swipeDirection;
  final bool showHeader;
  final bool showIndicator;
  final Duration indicatorPeriod;
  final double indicatorRadius;
  final double indicatorWidth;
  final Color? indicatorColor;
}

class EventConfig{
  const EventConfig({
    this.builder,
    required this.duration,
    required this.draggable,
    required this.resizable,
    required this.padding,
    required this.rounded,
    this.textStyle,
    this.overflow,
    this.maxLines,
    this.createAt = GestureType.doubleTap,
  });

  final EventBuilder? builder;
  final Duration duration;
  final bool draggable;
  final bool resizable;
  final double padding;
  final double rounded;
  final TextStyle? textStyle;
  final TextOverflow? overflow;
  final int? maxLines;
  final GestureType createAt;
}


class CalendarConfig extends InheritedWidget {
  const CalendarConfig({
    super.key,
    required super.child,
    required this.view,
    required this.line,
    required this.event,
    required this.header,
    this.time,
    this.date,
    this.week,
  });

  final ViewConfig view;
  final LineConfig line;
  final EventConfig event;
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
