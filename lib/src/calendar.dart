import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/calendar_tabled.dart';
import 'widgets/calendar_header.dart';
import 'utils/schemes.dart';
import 'data/fixture.dart';
import 'data/event.dart';
import 'modifier.dart';
import 'viewer.dart';
import 'source.dart';
import 'config.dart';
import 'enums.dart';
import 'const.dart';


class Calendar<T extends Event> extends StatelessWidget {

  const Calendar({
    super.key,
    required this.source,
    required this.view,
    this.scroll = CalendarScroll.snapping,
    //
    this.begHour = initialHour,
    this.endHour = finalHour,
    this.timeStep = stepHour,
    this.begDay = initialDay,
    this.endDay = finalDay,
    this.dateStep,
    this.begWeek = initialWeek,
    this.endWeek = finalWeek,
    //
    this.timeRatio = timeHeaderRatio,
    this.timeRound = timeHeaderRound,
    this.timeFormat,
    this.timePadding,
    this.timeTextStyle,
    this.timeBackground,
    //
    this.dateFormat,
    this.datePadding,
    this.dateTextStyle,
    this.dateBackground,
    //
    this.weekFormat,
    this.weekPadding,
    this.weekTextStyle,
    this.weekBackground,
    //
    this.headerFormat,
    this.headerPadding,
    this.headerTextStyle,
    this.headerBackground,
    this.showHeaderButtons = true,
    this.showHeaderView = true,
    this.showHeader = true,
    //
    this.lineStyle = lineFrameStyle,
    this.lineColor = lineFrameColor,
    this.lineWidth = lineFrameWidth,
    this.lineOffsetX = lineFrameOffsetX,
    this.lineOffsetY = lineFrameOffsetY,
    this.dashedWidth,
    this.dashedSpace,
    //
    this.showIndicator = true,
    this.indicatorColor,
    this.swipeDirection,
    //
    this.eventBuilder,
    this.eventDuration = eventSlotDuration,
    this.eventPadding = eventSlotPadding,
    this.eventRounded = eventSlotRounded,
    this.eventTileSize = eventSlotTileSize,
    this.eventTextStyle,
    this.eventTextMaxLines,
    this.eventTextOverflow,
    this.draggableEvent = true,
    this.resizableEvent = true,
    //
    this.onEventTap,
    this.onEventDoubleTap,
    this.onEventLongPress,
    this.onFrameTap,
    this.onFrameDoubleTap,
    this.onFrameLongPress,
    this.onEventDragged,
    this.onEventResized,
  });

  final CalendarSource<T> source;
  final CalendarView view;
  final CalendarScroll scroll;

  final int begDay;
  final int endDay;
  final int? dateStep;
  final int begWeek;
  final int endWeek;
  final int begHour;
  final int endHour;
  final int timeRound;
  final double timeRatio;
  final TimeStep timeStep;
  final String? timeFormat;
  final double? timePadding;
  final TextStyle? timeTextStyle;
  final Color? timeBackground;
  //
  final String? dateFormat;
  final double? datePadding;
  final TextStyle? dateTextStyle;
  final Color? dateBackground;
  //
  final String? weekFormat;
  final double? weekPadding;
  final TextStyle? weekTextStyle;
  final Color? weekBackground;
  //
  final String? headerFormat;
  final double? headerPadding;
  final TextStyle? headerTextStyle;
  final Color? headerBackground;

  final bool showHeader;
  final bool showHeaderButtons;
  final bool showHeaderView;
  //
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  //
  final bool showIndicator;
  final Color? indicatorColor;
  final Axis? swipeDirection;
  //
  final EventBuilder? eventBuilder;
  final TextStyle? eventTextStyle;
  final double eventPadding;
  final double eventRounded;
  final double eventTileSize;
  final int? eventTextMaxLines;
  final TextOverflow? eventTextOverflow;
  final Duration eventDuration;
  final bool draggableEvent;
  final bool resizableEvent;
  //
  final SlotCallback<T>? onEventTap;
  final SlotCallback<T>? onEventDoubleTap;
  final SlotCallback<T>? onEventLongPress;
  final PageCallback? onFrameTap;
  final PageCallback? onFrameDoubleTap;
  final PageCallback? onFrameLongPress;
  final ModifyCallback<T>? onEventDragged;
  final ModifyCallback<T>? onEventResized;

  CallbackScheme get callbacks => CallbackScheme(
    onFrameTap: onFrameTap,
    onFrameDoubleTap: onFrameDoubleTap,
    onFrameLongPress: onFrameLongPress,
    onEventTap: onEventTap != null
        ? (Event e) => onEventTap!(e as T)
        : null ,
    onEventDoubleTap: onEventDoubleTap != null
        ? (Event e) => onEventDoubleTap!(e as T)
        : null,
    onEventLongPress: onEventLongPress != null
        ? (Event e) => onEventLongPress!(e as T)
        : null,
    onEventDragged: draggableEvent
        ? (onEventDragged != null
            ? (Event e, Fixture f) => onEventDragged!(e as T, f)
            : null
        ) : null,
    onEventResized: resizableEvent
        ? (onEventResized != null
            ? (Event e, Fixture f) => onEventResized!(e as T, f)
            : null
        ) : null,
  );

  TimeScheme get timeScheme => TimeScheme(
    beg: begHour,
    end: endHour,
    step: timeStep,
    ratio: timeRatio,
    round: timeRound,
  );

  DateScheme get dateScheme => DateScheme(
    beg: begDay,
    end: endDay,
    step: dateStep ?? endDay - begDay,
  );

  WeekScheme get weekScheme => WeekScheme(
    beg: begWeek,
    end: endWeek,
  );

  LineConfig get lineConfig => LineConfig(
    style: lineStyle,
    color: lineColor,
    width: lineWidth,
    offsetX: lineOffsetX,
    offsetY: lineOffsetY,
    dashedWidth: dashedWidth,
    dashedSpace: dashedSpace,
  );

  ViewConfig get viewConfig => ViewConfig(
    showHeader: showHeaderView,
    showIndicator: showIndicator,
    indicatorColor: indicatorColor,
  );

  EventConfig get eventConfig => EventConfig(
    builder: eventBuilder ?? switch(view) {
      CalendarView.daily => null,
      CalendarView.weekly => null,
      CalendarView.monthly => (context, Event event) => Padding(
        padding: EdgeInsets.symmetric(horizontal: eventPadding),
        child: Center(child: Text(event.subject, maxLines: 1)),
      ),
    },
    padding: eventPadding,
    rounded: eventRounded,
    tileSize: eventTileSize,
    duration: eventDuration,
    draggable: draggableEvent,
    resizable: resizableEvent,
    swipeable: false,
  );

  TextConfig get headerConfig => switch (view) {
    CalendarView.daily => TextConfig(
      format: dateFormat ?? dailyHeaderFormat,
      padding: datePadding ?? dailyHeaderPadding,
      textStyle: dateTextStyle,
      background: dateBackground,
    ),
    CalendarView.weekly => TextConfig(
      format: dateFormat ?? weeklyHeaderFormat,
      padding: datePadding ?? weeklyHeaderPadding,
      textStyle: dateTextStyle,
      background: dateBackground,
    ),
    CalendarView.monthly => TextConfig(
      format: dateFormat ?? monthlyHeaderFormat,
      padding: datePadding ?? monthlyHeaderPadding,
      textStyle: dateTextStyle,
      background: dateBackground,
    ),
  };

  TextConfig get timeConfig {
    switch (view) {
      default:
        return TextConfig(
          format: timeFormat ?? timeHeaderFormat,
          padding: timePadding ?? timeHeaderPadding,
          textStyle: timeTextStyle,
          background: timeBackground,
        );
    }
  }

  TextConfig? get dateConfig {
    switch (view) {
      case CalendarView.daily:
        return TextConfig(
          format: dateFormat ?? dailyDateFormat,
          padding: datePadding ?? dailyDatePadding,
          textStyle: dateTextStyle,
          background: dateBackground,
        );
      case CalendarView.weekly:
        return TextConfig(
          format: dateFormat ?? weeklyDateFormat,
          padding: datePadding ?? weeklyDatePadding,
          textStyle: dateTextStyle,
          background: dateBackground,
        );
      case CalendarView.monthly:
        return TextConfig(
          format: dateFormat ?? monthlyDateFormat,
          padding: datePadding ?? monthlyDatePadding,
          textStyle: dateTextStyle,
          background: dateBackground,
        );
    }
  }

  TextConfig? get weekConfig {
    switch (view) {
      case CalendarView.daily:   return null;
      case CalendarView.weekly:  return null;
      case CalendarView.monthly:
        return TextConfig(
          format: dateFormat ?? monthlyWeekFormat,
          padding: datePadding ?? monthlyWeekPadding,
          textStyle: dateTextStyle,
          background: dateBackground,
        );
    }
  }

  Widget get viewer => switch (view) {
      CalendarView.daily => CalendarTabled(
          timeScheme: timeScheme,
          dateScheme: DateScheme.daily(),
          weekScheme: null,
          callbacks: callbacks,
        ),
      CalendarView.weekly => CalendarTabled(
          timeScheme: timeScheme,
          dateScheme: dateScheme,
          weekScheme: null,
          callbacks: callbacks,
        ),
      CalendarView.monthly => CalendarTabled(
          timeScheme: null,
          dateScheme: dateScheme,
          weekScheme: weekScheme,
          callbacks: callbacks,
        ),
  };

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CalendarEvents>.value(value: source),
        ChangeNotifierProvider(create: (_) => CalendarViewer(
          source,
          view: view,
          scroll: scroll,
        )),
        ChangeNotifierProvider(create: (_) => CalendarModifier(
          onEventDragged: callbacks.onEventDragged,
          onEventResized: callbacks.onEventResized,
          swipingDirection: viewConfig.scrollDirection(view),
          slidingDirection: viewConfig.slideDirection(view),
        ))
      ],
      builder: (context, _) {
        context.read<CalendarModifier>().attachSwiper(
            context.read<CalendarViewer>()
        );
        return CalendarConfig(
          view: viewConfig,
          line: lineConfig,
          event: eventConfig,
          header: headerConfig,
          time: timeConfig,
          date: dateConfig,
          week: weekConfig,
          child: Column(
            children: [
              CalendarTabledHeader(
                  showButtons: showHeaderButtons,
              ),
              Expanded(
                child: viewer,
              )
            ]
          ),
        );
      },
    );
  }
}
