import 'package:calendar/src/picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/schemes.dart';
import 'data/fixture.dart';
import 'data/event.dart';
import 'modifier.dart';
import 'viewer.dart';
import 'source.dart';
import 'config.dart';
import 'enums.dart';
import 'const.dart';


class CalendarDefaults {
  const CalendarDefaults({
    required this.dateScheme,
    required this.timeScheme,
    required this.weekScheme,
  });

  final DateScheme dateScheme;
  final TimeScheme? timeScheme;
  final WeekScheme? weekScheme;

  static const LineConfig lineConfig = LineConfig(
    style: lineFrameStyle,
    width: lineFrameWidth,
    offsetX: lineFrameOffsetX,
    offsetY: lineFrameOffsetY,
  );

  static const ClockConfig clockConfig = ClockConfig(
    period: timeIndicatorPeriod,
    radius: timeIndicatorPointRadius,
    width: timeIndicatorLineWidth,
  );

  static const EventConfig eventConfig = EventConfig(
    duration: eventSlotDuration,
    padding: eventSlotPadding,
    rounded: eventSlotRounded,
  );

  static const _daily = CalendarDefaults(
    dateScheme: DateScheme.daily(),
    timeScheme: TimeScheme.allDay(),
    weekScheme: null,
  );

  static const _weekly = CalendarDefaults(
    dateScheme: DateScheme.weekly(),
    timeScheme: TimeScheme.allDay(),
    weekScheme: null,
  );

  static const _monthly = CalendarDefaults(
    dateScheme: DateScheme.weekly(),
    timeScheme: null,
    weekScheme: WeekScheme.general(),
    );

  static CalendarDefaults of(BuildContext context, CalendarView view) => switch (view) {
    CalendarView.daily   => _daily,
    CalendarView.weekly  => _weekly,
    CalendarView.monthly => _monthly,
  };
}


abstract class CalendarBase<T extends Event> extends StatelessWidget {

  const CalendarBase({
    super.key,
    required this.source,
    required this.view,
    required this.scroll,
    this.dateScheme,
    this.timeScheme,
    this.weekScheme,
    //
    this.headerConfig,
    this.eventConfig,
    this.clockConfig,
    this.dateConfig,
    this.timeConfig,
    this.weekConfig,
    this.lineConfig,
    //
    this.headerBuilder,
    this.eventBuilder,
    this.leftSwipeBuilder,
    this.rightSwipeBuilder,
    this.cornerBuilder,
    //
    this.draggableEvent = false,
    this.resizableEvent = false,
    this.swipeableEvent = false,
    //
    this.showFrame = true,
    this.showHeader = true,
    this.showHeaderWidget = true,
    this.showHeaderButton = true,
    this.showIndicator = true,
    //
    this.onEventTap,
    this.onEventDoubleTap,
    this.onEventLongPress,
    this.onFrameTap,
    this.onFrameDoubleTap,
    this.onFrameLongPress,
    this.onEventDragged,
    this.onEventResized,
    this.onEventSwipedLeft,
    this.onEventSwipedRight,
    //
    this.centredView = true,
    this.shrinkableAgenda = false,
    this.negligibleAgenda = false,
    this.fixLastAnchor = true,
    this.fixNextAnchor = true,
    this.lastAnchorBuilder,
    this.nextAnchorBuilder,
    this.emptyBuilder,
    this.appbar = const [],
  });

  final CalendarSource<T> source;
  final CalendarView view;
  final CalendarScroll scroll;
  final DateScheme? dateScheme;
  final TimeScheme? timeScheme;
  final WeekScheme? weekScheme;
  // //
  // final int begDay;
  // final int endDay;
  // final int? dateStep;
  // final int begWeek;
  // final int endWeek;
  // //
  // final int begHour;
  // final int endHour;
  // final int timeRound;
  // final double timeRatio;
  // final TimeStep timeStep;
  //
  final bool showFrame;
  final bool showHeader;
  final bool showHeaderWidget;
  final bool showHeaderButton;
  final bool showIndicator;
  //
  final HeaderBuilder? headerBuilder;
  final EventBuilder<T>? eventBuilder;
  final WidgetBuilder? leftSwipeBuilder;
  final WidgetBuilder? rightSwipeBuilder;
  final WidgetBuilder? cornerBuilder;
  final bool draggableEvent;
  final bool resizableEvent;
  final bool swipeableEvent;
  //
  final SlotCallback<T>? onEventTap;
  final SlotCallback<T>? onEventDoubleTap;
  final SlotCallback<T>? onEventLongPress;
  final PageCallback? onFrameTap;
  final PageCallback? onFrameDoubleTap;
  final PageCallback? onFrameLongPress;
  final ModifyCallback<T>? onEventDragged;
  final ModifyCallback<T>? onEventResized;
  final ModifyCallback<T>? onEventSwipedLeft;
  final ModifyCallback<T>? onEventSwipedRight;
  //
  final HeaderConfig? headerConfig;
  final EventConfig? eventConfig;
  final ClockConfig? clockConfig;
  final TextConfig? timeConfig;
  final TextConfig? dateConfig;
  final TextConfig? weekConfig;
  final LineConfig? lineConfig;
  //
  final bool centredView;
  final bool shrinkableAgenda;
  final bool negligibleAgenda;
  final bool fixLastAnchor;
  final bool fixNextAnchor;
  final WidgetBuilder? lastAnchorBuilder;
  final WidgetBuilder? nextAnchorBuilder;
  final WidgetBuilder? emptyBuilder;
  final List<Widget> appbar;


  CallbackScheme get callbacks => CallbackScheme(
    onFrameTap: onFrameTap,
    onFrameDoubleTap: onFrameDoubleTap,
    onFrameLongPress: onFrameLongPress,
    onEventTap: onEventTap != null
        ? (Event e) => onEventTap!(e as T)
        : null,
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


  Widget buildViewer(
      BuildContext context,
      DateScheme dateScheme,
      TimeScheme? timeScheme,
      WeekScheme? weekScheme,
    );

  @nonVirtual
  @override
  Widget build(BuildContext context) {
    final defaults = CalendarDefaults.of(context, view);
    final calendar = CalendarConfig(
      header: headerConfig,
      date: dateConfig,
      week: weekConfig,
      time: timeConfig,
      line: CalendarDefaults.lineConfig.merge(lineConfig),
      clock: CalendarDefaults.clockConfig.merge(clockConfig),
      event: CalendarDefaults.eventConfig.merge(eventConfig),
      centred: centredView,
      showFrame: showFrame,
      showHeader: showHeader,
      showHeaderWidget: showHeaderWidget,
      showHeaderButton: showHeaderButton,
      showIndicator: showIndicator,
      eventDraggable: draggableEvent,
      eventResizable: resizableEvent,
      eventSwipeable: swipeableEvent,
      fixLastAnchor: fixLastAnchor,
      fixNextAnchor: fixNextAnchor,
      shrinkableAgenda: shrinkableAgenda,
      negligibleAgenda: negligibleAgenda,
      emptyBuilder: emptyBuilder,
      headerBuilder: headerBuilder,
      eventBuilder: eventBuilder != null
          ? (context, e) => eventBuilder!(context, e as T)
          : null,
      leftSwipeBuilder: leftSwipeBuilder,
      rightSwipeBuilder: rightSwipeBuilder,
      lastAnchorBuilder: lastAnchorBuilder,
      nextAnchorBuilder: nextAnchorBuilder,
      child: buildViewer(context,
        dateScheme ?? defaults.dateScheme,
        timeScheme ?? defaults.timeScheme,
        weekScheme ?? defaults.weekScheme,
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CalendarEvents>.value(value: source),
        ChangeNotifierProvider(create: (_) => CalendarViewer(
          view: view,
          scroll: scroll,
        )),
        ChangeNotifierProvider(create: (_) => CalendarPicker(
          view: (weekScheme != null)
              ? CalendarView.monthly
              : CalendarView.weekly,
          scroll: scroll,
        )),
        ChangeNotifierProvider(create: (_) => CalendarModifier(
          onEventDragged: callbacks.onEventDragged,
          onEventResized: callbacks.onEventResized,
          swipingDirection: calendar.scrollDirection(view),
          slidingDirection: calendar.slideDirection(view),
        ))
      ],
      builder: (context, _) {
        context.read<CalendarModifier>().attachSwiper(context.read<CalendarViewer>());
        context.read<CalendarPicker>().attachViewer(context.read<CalendarViewer>());
        return calendar;
      },
    );
  }
}
