import 'package:flutter/material.dart';
import 'enums.dart';
import 'const.dart';


class LineConfig {

  const LineConfig({
    this.style,
    this.width,
    this.offsetX,
    this.offsetY,
    this.color,
    this.length,
    this.dashedWidth,
    this.dashedSpace,
  });

  final LineStyle? style;
  final Color? color;
  final double? width;
  final double? length;
  final double? offsetX;
  final double? offsetY;
  final double? dashedWidth;
  final double? dashedSpace;

  LineStyle get lineStyle => style ?? LineStyle.solid;
  double get lineOffsetX => offsetX ?? 0.0;
  double get lineOffsetY => offsetY ?? 0.0;
  double get lineWidth => width ?? 1.0;
  Color? get lineColor => color;

  LineConfig merge(LineConfig? other) => other == null ? this : LineConfig(
    style:        other.style       ?? style,
    color:        other.color       ?? color,
    width:        other.width       ?? width,
    offsetX:      other.offsetX     ?? offsetX,
    offsetY:      other.offsetY     ?? offsetY,
    length:       other.length      ?? length,
    dashedWidth:  other.dashedWidth ?? dashedWidth,
    dashedSpace:  other.dashedSpace ?? dashedSpace,
  );

  LineConfig resolve(BuildContext context) {
    if (color != null) return this;
    return merge(LineConfig(
      color: Theme.of(context).colorScheme.outlineVariant,
    ));
  }

  factory LineConfig.of(BuildContext context) => LineConfig(
    color: Theme.of(context).colorScheme.outlineVariant,
  );
}


class TextConfig{
  const TextConfig({
    this.format,
    this.padding,
    this.textStyle,
    this.background,
  });

  final String? format;
  final double? padding;
  final TextStyle? textStyle;
  final Color? background;

  double get textPadding => padding ?? 0.0;

  TextConfig merge(TextConfig? other) => other == null ? this : TextConfig(
    format:     other.format     ?? format,
    padding:    other.padding    ?? padding,
    textStyle:  other.textStyle  ?? textStyle,
    background: other.background ?? background,
  );
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

  @override
  HeaderConfig merge(covariant HeaderConfig? other) => other == null ? this : HeaderConfig(
    builder:    other.builder    ?? builder,
    format:     other.format     ?? format,
    padding:    other.padding    ?? padding,
    textStyle:  other.textStyle  ?? textStyle,
    background: other.background ?? background,
  );
}


class ClockConfig{
  const ClockConfig({
    this.period,
    this.radius,
    this.width,
    this.color,
  });

  final Duration? period;
  final double? radius;
  final double? width;
  final Color? color;

  Duration get clockPeriod => period ?? Duration(minutes: 1);
  double get clockRadius => radius ?? 5.0;
  double get clockWidth => width ?? 1.0;
  Color? get clockColor => color;

  ClockConfig merge(ClockConfig? other) => other == null ? this : ClockConfig(
    period:  other.period ?? period,
    radius:  other.radius ?? radius,
    width:   other.width  ?? width,
    color:   other.color  ?? color,
  );

  factory ClockConfig.of(BuildContext context) => ClockConfig(
    color: Theme.of(context).colorScheme.primary,
  );
}


class EventConfig{
  const EventConfig({
    this.duration,
    this.padding,
    this.rounded,
    this.extent,
    this.textStyle,
    this.overflow,
    this.maxLines,
    this.draggable,
    this.resizable,
    this.swipeable,
  });

  final Duration? duration;
  final double? padding;
  final double? rounded;
  final double? extent;
  final TextStyle? textStyle;
  final TextOverflow? overflow;
  final int? maxLines;
  final EditEvent? draggable;
  final EditEvent? resizable;
  final EditEvent? swipeable;

  Duration get eventDuration => duration ?? Duration(milliseconds: 200);
  double get eventPadding => padding ?? 0.0;
  double get eventRounded => rounded ?? 0.0;
  double get eventExtent => extent ?? 0.0;

  EventConfig merge(EventConfig? other) => other == null ? this : EventConfig(
    duration:           other.duration ?? duration,
    padding:            other.padding ?? padding,
    rounded:            other.rounded ?? rounded,
    extent:             other.extent ?? extent,
    textStyle:          other.textStyle ?? textStyle,
    maxLines:           other.maxLines ?? maxLines,
    overflow:           other.overflow ?? overflow,
    draggable:          other.draggable ?? draggable,
    resizable:          other.draggable ?? resizable,
    swipeable:          other.draggable ?? swipeable,
  );
}


class CalendarConfig extends InheritedWidget {
  const CalendarConfig({
    super.key,
    required super.child,
    required this.line,
    required this.event,
    required this.clock,
    required this.header,
    required this.date,
    this.time,
    this.week,
    this.centred = true,
    this.showFrame = true,
    this.showHeader = true,
    this.showHeaderWidget = true,
    this.showHeaderButton = true,
    this.fixLastAnchor = true,
    this.fixNextAnchor = true,
    this.showIndicator = true,
    this.eventDraggable = false,
    this.eventResizable = false,
    this.eventSwipeable = false,
    this.shrinkableAgenda = false,
    this.negligibleAgenda = false,
    this.headerBuilder,
    this.eventBuilder,
    this.leftSwipeBuilder,
    this.rightSwipeBuilder,
    this.lastAnchorBuilder,
    this.nextAnchorBuilder,
    this.emptyBuilder,
  });

  final LineConfig line;
  final EventConfig event;
  final ClockConfig clock;
  final HeaderConfig header;
  final TextConfig date;
  final TextConfig? time;
  final TextConfig? week;
  final bool centred;
  final bool showFrame;
  final bool showHeader;
  final bool showHeaderWidget;
  final bool showHeaderButton;
  final bool fixLastAnchor;
  final bool fixNextAnchor;
  final bool showIndicator;
  final bool eventDraggable;
  final bool eventResizable;
  final bool eventSwipeable;
  final bool shrinkableAgenda;
  final bool negligibleAgenda;
  final HeaderBuilder? headerBuilder;
  final EventBuilder? eventBuilder;
  final WidgetBuilder? leftSwipeBuilder;
  final WidgetBuilder? rightSwipeBuilder;
  final WidgetBuilder? lastAnchorBuilder;
  final WidgetBuilder? nextAnchorBuilder;
  final WidgetBuilder? emptyBuilder;

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
        || clock != oldWidget.clock
        || header != oldWidget.header
        || time != oldWidget.time
        || date != oldWidget.date
        || week != oldWidget.week;
  }
}
