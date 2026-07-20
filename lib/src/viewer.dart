import 'package:calendar/src/source.dart';
import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'enums.dart';


extension on Date {
  Date get start => this;
  Date get stop => start + 1;
}

extension on Week {
  Date get start => mon;
  Date get stop => start + 7;
}

extension on Month {
  Date get start => weekStart.date;
  Date get stop => start + 42;
}


class CalendarViewer extends ChangeNotifier {

  final CalendarView view;
  final CalendarEvents source;
  late DateTime _datetime;
  CalendarSwipe? _swiping;
  double offset = 0.0;

  CalendarViewer(this.source, this.view) {
    switch (view) {
      case CalendarView.daily:   _datetime = Date.now();
      case CalendarView.weekly:  _datetime = Week.now();
      // case CalendarView.monthly:  _datetime = Month.now();
    }
    update();
  }

  // Getter tipizzati — il cast è in un posto solo
  Date  get asDate  => _datetime.date;
  Week  get asWeek  => _datetime.toWeek;
  Month get asMonth => _datetime.toMonth;

  // Mantenuto per retrocompatibilità
  DateTime get datetime => _datetime;
  CalendarSwipe? get swiping => _swiping;

  Date get start {
    switch(view) {
      case CalendarView.daily:   return (_datetime as Date).start;
      case CalendarView.weekly:  return (_datetime as Week).start;
    // case CalendarView.monthly: return (_datetime as Month).start;
    }
  }

  Date get stop {
    switch(view) {
      case CalendarView.daily:   return (_datetime as Date).stop;
      case CalendarView.weekly:  return (_datetime as Week).stop;
    // case CalendarView.monthly: return (_datetime as Month).stop;
    }
  }

  void update() {
    final from = (start.date - 1).toMonth.start;
    final to = (stop.date + 1).toMonth.stop;
    source.build(from, to);
  }

  void next([bool swiping = false]) {
    _datetime = (_datetime as dynamic) + 1;
    if (swiping) return swipe(CalendarSwipe.forward);
    Future.microtask(() => update());
    notifyListeners();
  }

  void last([bool swiping = false]) {
    _datetime = (_datetime as dynamic) - 1;
    if (swiping) return swipe(CalendarSwipe.backward);
    Future.microtask(() => update());
    notifyListeners();
  }

  void swipe(CalendarSwipe swipe) {
    _swiping = swipe;
    notifyListeners();
  }

  void clear() {
    _swiping = null;
  }

  String title(BuildContext context) {
    final header = CalendarConfig.of(context)!.header;
    switch (view) {
      case CalendarView.weekly:
        final week = asWeek;
        return "${week.mon.format(header.format)} "
            "─ ${week.sun.format(header.format)}";
      default:
        return datetime.format(header.format);
    }
  }
}
