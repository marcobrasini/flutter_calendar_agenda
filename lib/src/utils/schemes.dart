import 'package:calendar/src/const.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/utils/datetime.dart';


class TimeScheme {
  const TimeScheme({
    this.beg = initialHour,
    this.end = finalHour,
    this.step = TimeStep.minutes60,
    this.ratio = 1.0,
    this.round = 1,
  });
  final int beg;
  final int end;
  final TimeStep step;
  final double ratio;
  final int round;
  Time get from   => (beg == initialHour) ? Time.beg : Time(beg, 0);
  Time get to     => (end == finalHour)   ? Time.end : Time(end, 0);
  int get hours   => (to % from) ~/ Duration.minutesPerHour;
  int get minutes => hours * Duration.minutesPerHour;
  int get count   => (to % from) ~/ step.minutes;
  double scale(double space) => minutes / space;

  factory TimeScheme.allDay() => TimeScheme(
      beg: 0, end: 24,
      step: TimeStep.hours24
  );
}

class DateScheme {
  const DateScheme({
    this.beg = initialDay,
    this.end = finalDay,
    this.step = DateTime.daysPerWeek,
  });
  final int beg;
  final int end;
  final int step;
  int get count => end - beg;
  double scale(double space) => count / space;

  const DateScheme.daily()  : this(beg: 0, end: 1, step: 1);
  const DateScheme.weekly() : this(beg: 0, end: 7, step: 7);
}


class WeekScheme {
  const WeekScheme({
    this.beg = initialWeek,
    this.end = finalWeek,
  });
  final int beg;
  final int end;
  static const int step = 7;
  int get count => end - beg;
  double scale(double space) => count / space;
}

class CallbackScheme {
  const CallbackScheme({
    this.onEventTap,
    this.onEventDoubleTap,
    this.onEventLongPress,
    this.onFrameTap,
    this.onFrameDoubleTap,
    this.onFrameLongPress,
    this.onEventCreated,
    this.onEventUpdated,
    this.onEventDeleted,
    this.onEventDragged,
    this.onEventResized,
    this.onEventSwipedLeft,
    this.onEventSwipedRight,
  });
  final SlotCallback? onEventTap;
  final SlotCallback? onEventDoubleTap;
  final SlotCallback? onEventLongPress;
  final PageCallback? onFrameTap;
  final PageCallback? onFrameDoubleTap;
  final PageCallback? onFrameLongPress;
  final CreateCallback? onEventCreated;
  final ModifyCallback? onEventUpdated;
  final DeleteCallback? onEventDeleted;
  final ModifyCallback? onEventDragged;
  final ModifyCallback? onEventResized;
  final ModifyCallback? onEventSwipedLeft;
  final ModifyCallback? onEventSwipedRight;
}
