import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/timer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/tools/header_calendar.dart';
import 'widgets/views/view_daily.dart';
import 'widgets/views/view_weekly.dart';
import 'widgets/views/view_monthly.dart';
import 'utils/schemes.dart';
import 'enums.dart';
import 'const.dart';
import 'config.dart';
import 'viewer.dart';


class Calendar extends StatelessWidget {

  const Calendar({
    super.key,
    required this.view,
    required this.source,
    this.begHour = initialHour,
    this.endHour = finalHour,
    this.timeStep = stepHour,
    this.begDay = initialDay,
    this.endDay = finalDay,
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
    this.onEventCreated,
  });

  final CalendarView view;
  final CalendarSource source;

  final int begDay;
  final int endDay;
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
  final int? eventTextMaxLines;
  final TextOverflow? eventTextOverflow;
  final Duration eventDuration;
  final bool draggableEvent;
  final bool resizableEvent;
  //
  final SlotCallback? onEventTap;
  final SlotCallback? onEventDoubleTap;
  final SlotCallback? onEventLongPress;
  final PageCallback? onFrameTap;
  final PageCallback? onFrameDoubleTap;
  final PageCallback? onFrameLongPress;
  final ModifyCallback? onEventDragged;
  final ModifyCallback? onEventResized;
  final CreateCallback? onEventCreated;

  CallbackScheme get callbacks => CallbackScheme(
    onEventTap: onEventTap,
    onEventDoubleTap: onEventDoubleTap,
    onEventLongPress: onEventLongPress,
    onFrameTap: onFrameTap,
    onFrameDoubleTap: onFrameDoubleTap,
    onFrameLongPress: onFrameLongPress,
    onEventDragged: draggableEvent ? onEventDragged : null,
    onEventResized: resizableEvent ? onEventResized : null,
    onEventCreated: onEventCreated,
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
    swipeDirection: swipeDirection
        ?? (view == CalendarView.monthly ? Axis.vertical : Axis.horizontal),
  );

  EventConfig get eventConfig => EventConfig(
    builder: eventBuilder,
    padding: eventPadding,
    rounded: eventRounded,
    duration: eventDuration,
    draggable: draggableEvent,
    resizable: resizableEvent,
  );

  TextConfig get headerConfig {
    switch (view) {
      case CalendarView.daily:
        return TextConfig(
          format: dateFormat ?? dailyHeaderFormat,
          padding: datePadding ?? dailyHeaderPadding,
          textStyle: dateTextStyle,
          background: dateBackground,
        );
      case CalendarView.weekly:
        return TextConfig(
          format: dateFormat ?? weeklyHeaderFormat,
          padding: datePadding ?? weeklyHeaderPadding,
          textStyle: dateTextStyle,
          background: dateBackground,
        );
      case CalendarView.monthly:
        return TextConfig(
          format: dateFormat ?? monthlyHeaderFormat,
          padding: datePadding ?? monthlyHeaderPadding,
          textStyle: dateTextStyle,
          background: dateBackground,
        );
    }
  }

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

  Widget get viewer {
    switch (view) {
      case CalendarView.daily:
        return DailyView(
          timeScheme: timeScheme,
          callbacks: callbacks,
        );
      case CalendarView.weekly:
        return WeeklyView(
          dateScheme: dateScheme,
          timeScheme: timeScheme,
          callbacks: callbacks,
        );
      case CalendarView.monthly:
        return MonthlyView(
          dateScheme: dateScheme,
          weekScheme: weekScheme,
          callbacks: callbacks,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => source),
        ChangeNotifierProvider(create: (_) => CalendarViewer(view)),
        ChangeNotifierProvider(create: (_) => CalendarTimer()),
        ChangeNotifierProvider(create: (_) => CalendarModifier(
          onEventDragged: callbacks.onEventDragged,
          onEventResized: callbacks.onEventResized,
        ))
      ],
      builder: (context, _) {
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
              CalendarHeader(
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
