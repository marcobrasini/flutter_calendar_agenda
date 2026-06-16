import 'package:calendar/src/const.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/utils/datetime.dart';


class TimeScheme {
  const TimeScheme({
    this.beg = initialHour,
    this.end = finalHour,
    this.step = TimeStep.minutes60,
    this.ratio = 1.0,
    this.round,
  });
  final int beg;
  final int end;
  final TimeStep step;
  final double ratio;
  final int? round;
  Time get from   => (beg == initialHour) ? Time.beg : Time(beg, 0);
  Time get to     => (end == finalHour)   ? Time.end : Time(end, 0);
  int get hours   => (end - beg) % (Duration.hoursPerDay + 1);
  int get minutes => hours * Duration.minutesPerHour;
  int get count   => hours * (Duration.minutesPerHour ~/ step.minutes) + 1;
  double scale(double space) => minutes / space;
}

class DateScheme {
  const DateScheme({
    this.beg = initialDay,
    this.end = finalDay,
  });
  final int beg;
  final int end;
  int get count => (end - beg) % DateTime.daysPerWeek + 1;
  double scale(double space) => count / space;
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
    this.onEventDragged,
    this.onEventResized,
    this.onEventDeleted,
  });
  final EventCallback? onEventTap;
  final EventCallback? onEventDoubleTap;
  final EventCallback? onEventLongPress;
  final FrameCallback? onFrameTap;
  final FrameCallback? onFrameDoubleTap;
  final FrameCallback? onFrameLongPress;
  final CreateCallback? onEventCreated;
  final ModifyCallback? onEventDragged;
  final ModifyCallback? onEventResized;
  final DeleteCallback? onEventDeleted;
}
