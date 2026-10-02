import 'package:calendar/src/const.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/utils/datetime.dart';


class TimeScheme {
  const TimeScheme(
    this.beg, this.end, {
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

  const TimeScheme.allDay() : this(0, 24, step: TimeStep.hours24);
}


class DateScheme {
  const DateScheme(
    this.beg, this.end, {
    int? step,
  }) : step = step ?? end - beg;

  final int beg;
  final int end;
  final int step;
  int get count => end - beg;
  double scale(double space) => count / space;

  const DateScheme.daily()  : this(0, 1);
  const DateScheme.weekly() : this(0, 7);

  List<Date> iterate(DateTime datetime) => List<Date>.generate(
      count, (i) => datetime.date - beg + i
  );
}


class WeekScheme {
  const WeekScheme(
    this.beg, this.end,
  );
  final int beg;
  final int end;
  static const int step = 7;
  int get count => end - beg;
  double scale(double space) => count / space;

  const WeekScheme.general() : this(0, 6);
}
