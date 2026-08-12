import 'package:flutter/material.dart';
import 'enums.dart';
import 'const.dart';


class TextConfig{
  const TextConfig({
    this.format,
    this.padding = 0.0,
    this.textStyle,
    this.background,
  });

  final String? format;
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
    this.showHeaderButton = true,
    this.showIndicator = true,
    this.indicatorPeriod = timeIndicatorPeriod,
    this.indicatorRadius = timeIndicatorPointRadius,
    this.indicatorWidth = timeIndicatorLineWidth,
    this.indicatorColor,
  });

  final bool showHeader;
  final bool showHeaderButton;
  final bool showIndicator;
  final Duration indicatorPeriod;
  final double indicatorRadius;
  final double indicatorWidth;
  final Color? indicatorColor;

  Axis scrollDirection(CalendarView view) => switch(view) {
    CalendarView.daily    => Axis.horizontal,
    CalendarView.weekly   => Axis.horizontal,
    CalendarView.monthly  => Axis.vertical,
  };

  Axis slideDirection(CalendarView view) => switch(view) {
    CalendarView.daily    => Axis.vertical,
    CalendarView.weekly   => Axis.vertical,
    CalendarView.monthly  => Axis.horizontal,
  };
}


class EventConfig{
  const EventConfig({
    this.builder,
    required this.duration,
    required this.draggable,
    required this.resizable,
    required this.swipeable,
    required this.padding,
    required this.rounded,
    required this.extent,
    this.textStyle,
    this.overflow,
    this.maxLines,
    this.leftSwipeBuilder,
    this.rightSwipeBuilder,
  });

  final EventBuilder? builder;
  final Duration duration;
  final bool draggable;
  final bool resizable;
  final bool swipeable;
  final double padding;
  final double rounded;
  final double extent;
  final TextStyle? textStyle;
  final TextOverflow? overflow;
  final int? maxLines;
  final WidgetBuilder? leftSwipeBuilder;
  final WidgetBuilder? rightSwipeBuilder;
}

class HeaderConfig extends TextConfig {
  const HeaderConfig({
    this.builder,
    super.format,
    super.padding,
    super.textStyle,
    super.background,
  });

  final HeaderBuilder? builder;
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
  final HeaderConfig header;
  final TextConfig? time;
  final TextConfig? date;
  final TextConfig? week;

  static CalendarConfig? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CalendarConfig>();
  }

  static CalendarConfig of(BuildContext context) {
    final CalendarConfig? config = maybeOf(context);
    assert(config != null, 'No CalendarConfig found in context');
    return config!;
  }

  @override
  bool updateShouldNotify(CalendarConfig oldWidget) {
    return line != oldWidget.line
        || event != oldWidget.event
        || header != oldWidget.header
        || time != oldWidget.time
        || date != oldWidget.date
        || week != oldWidget.week;
  }
}
