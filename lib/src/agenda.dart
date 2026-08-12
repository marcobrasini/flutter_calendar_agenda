import 'package:calendar/calendar.dart';
import 'package:calendar/src/config.dart';
import 'package:calendar/src/const.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/modifier.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:calendar/src/widgets/calendar_agenda.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/event.dart';
import 'data/fixture.dart';



class Agenda<T extends Event> extends StatelessWidget {
  const Agenda({
    super.key,
    required this.view,
    required this.source,
    this.scroll = CalendarScroll.continuous,
    this.begDay = initialDay,
    this.endDay = finalDay,
    this.dateStep,
    //
    this.dateFormat,
    this.datePadding,
    this.dateTextStyle,
    this.dateBackground,
    //
    this.showHeader = true,
    this.showHeaderButtons = true,
    this.headerBuilder,
    this.headerFormat,
    this.headerPadding,
    this.headerTextStyle,
    this.headerBackground,
    //
    this.lineStyle = lineFrameStyle,
    this.lineColor = lineFrameColor,
    this.lineWidth = lineFrameWidth,
    this.lineOffsetX = lineFrameOffsetX,
    this.lineOffsetY = lineFrameOffsetY,
    this.dashedWidth,
    this.dashedSpace,
    //
    this.eventBuilder,
    this.eventDuration = eventSlotDuration,
    this.eventPadding = eventSlotPadding,
    this.eventRounded = eventSlotRounded,
    this.eventExtent,
    this.eventTextStyle,
    this.eventTextMaxLines,
    this.eventTextOverflow,
    this.draggableEvent = true,
    this.swipeableEvent = true,
    //
    this.onEventTap,
    this.onEventDoubleTap,
    this.onEventLongPress,
    this.onFrameTap,
    this.onFrameDoubleTap,
    this.onFrameLongPress,
    this.onEventDragged,
    this.onEventSwipedLeft,
    this.onEventSwipedRight,
    //
    this.swipedLeftBuilder,
    this.swipedRightBuilder,
  });

  final CalendarView view;
  final CalendarScroll scroll;
  final CalendarSource<T> source;

  final int begDay;
  final int endDay;
  final int? dateStep;

  final String? dateFormat;
  final double? datePadding;
  final TextStyle? dateTextStyle;
  final Color? dateBackground;

  final HeaderBuilder? headerBuilder;
  final String? headerFormat;
  final double? headerPadding;
  final TextStyle? headerTextStyle;
  final Color? headerBackground;
  final bool showHeader;
  final bool showHeaderButtons;

  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;

  final EventBuilder? eventBuilder;
  final TextStyle? eventTextStyle;
  final double eventPadding;
  final double eventRounded;
  final double? eventExtent;
  final int? eventTextMaxLines;
  final TextOverflow? eventTextOverflow;
  final Duration eventDuration;
  final bool draggableEvent;
  final bool swipeableEvent;

  final SlotCallback<T>? onEventTap;
  final SlotCallback<T>? onEventDoubleTap;
  final SlotCallback<T>? onEventLongPress;
  final PageCallback? onFrameTap;
  final PageCallback? onFrameDoubleTap;
  final PageCallback? onFrameLongPress;
  final ModifyCallback<T>? onEventDragged;
  final ModifyCallback<T>? onEventSwipedLeft;
  final ModifyCallback<T>? onEventSwipedRight;

  final WidgetBuilder? swipedLeftBuilder;
  final WidgetBuilder? swipedRightBuilder;

  DateScheme get dateScheme => DateScheme(
    beg: begDay,
    end: endDay,
    step: dateStep ?? endDay - begDay,
  );

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
    onEventSwipedLeft: swipeableEvent
        ? (onEventSwipedLeft != null
        ? (Event e, Fixture f) => onEventSwipedLeft!(e as T, f)
        : null
    ) : null,
    onEventSwipedRight: swipeableEvent
        ? (onEventSwipedRight != null
        ? (Event e, Fixture f) => onEventSwipedRight!(e as T, f)
        : null
    ) : null,
  );

  ViewConfig get viewConfig => ViewConfig(
    showHeader: showHeader,
    showHeaderButton: showHeaderButtons
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
    extent: eventExtent ?? eventSlotAgendaExtent,
    duration: eventDuration,
    draggable: draggableEvent,
    swipeable: swipeableEvent,
    resizable: false,
    leftSwipeBuilder: swipedLeftBuilder,
    rightSwipeBuilder: swipedRightBuilder,
  );

  HeaderConfig get headerConfig => HeaderConfig(
    builder: headerBuilder,
    format: dateFormat ?? switch (view) {
      CalendarView.daily => dailyHeaderFormat,
      CalendarView.weekly => weeklyHeaderFormat,
      CalendarView.monthly => monthlyHeaderFormat,
    },
    padding: datePadding ?? switch (view) {
      CalendarView.daily => dailyHeaderPadding,
      CalendarView.weekly => weeklyHeaderPadding,
      CalendarView.monthly => monthlyHeaderPadding,
    },
    textStyle: dateTextStyle,
    background: dateBackground,
  );

  TextConfig get dateConfig => TextConfig(
    format: dateFormat ?? switch (view) {
      CalendarView.daily => dailyDateFormat,
      CalendarView.weekly => weeklyDateFormat,
      CalendarView.monthly => monthlyDateFormat,
    },
    padding: datePadding ?? switch (view) {
      CalendarView.daily => dailyDatePadding,
      CalendarView.weekly => weeklyDatePadding,
      CalendarView.monthly => monthlyDatePadding,
    },
    textStyle: dateTextStyle,
    background: dateBackground,
  );

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
          )),
        ],
        builder: (context, _) {
          return CalendarConfig(
            line: lineConfig,
            view: viewConfig,
            event: eventConfig,
            header: headerConfig,
            date: dateConfig,
            child: CalendarAgenda(
              callbacks: callbacks,
              scrolling: scroll,
            ),
          );
        },
    );
  }
}
