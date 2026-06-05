import 'dart:ui';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/const.dart';
import 'package:calendar/src/utils/datetime.dart';


mixin TimeScheme {
  int get begHour;
  int get endHour;
  int get timeStep;
  int get hours => (endHour - begHour) % (Duration.hoursPerDay + 1);
  int get minutes => hours * Duration.minutesPerHour;
  Time get from => (begHour == initialHour) ? Time.beg : Time(begHour, 0);
  Time get to => (endHour == finalHour) ? Time.end : Time(endHour, 0);
  // double timeScale(double space) => minutes / space;
}


mixin DateScheme {
  int get begDay;
  int get endDay;
  int get dateStep;
  int get days => (endDay - begDay) % (DateTime.daysPerWeek) + 1;
  // double dateScale(double space) => dateSlots / space;
}


mixin WeekScheme {
  int get begWeek;
  int get endWeek;
  int get weekStep;
  int get weeks => (endWeek - begWeek) % (weekMonthSlots + 1);
  // double weekScale(double space) => weekSlots / space;
}
