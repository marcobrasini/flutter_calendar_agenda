import 'package:calendar/src/source.dart';
import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'enums.dart';


extension CalendarDate on Date {
  Date get start => this;
  Date get stop => this;
}

extension CalendarWeek on Week {
  Date get start => mon;
  Date get stop => sun;
}

extension CalendarMonth on Month {
  Date get start => first.weekStart.date;
  Date get stop => last.weekEnd.date;
}


class CalendarViewer extends ChangeNotifier {

  final CalendarView view;
  final CalendarEvents source;
  final CalendarController controller;
  late DateTime _datetime;
  CalendarSwipe? _swiping;

  CalendarViewer(this.source, this.view) : controller = CalendarController() {
    switch (view) {
      case CalendarView.daily:   _datetime = Date.now();
      case CalendarView.weekly:  _datetime = Week.now();
      case CalendarView.monthly: _datetime = Month.now();
    }
    controller.datetime = _datetime;
  }

  dynamic get datetime => _datetime;
  Date  get asDate  => _datetime.date;
  Week  get asWeek  => _datetime.toWeek;
  Month get asMonth => _datetime.toMonth;
  CalendarSwipe? get swiping => _swiping;

  Date get start {
    switch(view) {
      case CalendarView.daily:   return (_datetime as Date).start;
      case CalendarView.weekly:  return (_datetime as Week).start;
      case CalendarView.monthly: return (_datetime as Month).start;
    }
  }

  Date get stop {
    switch(view) {
      case CalendarView.daily:   return (_datetime as Date).stop;
      case CalendarView.weekly:  return (_datetime as Week).stop;
      case CalendarView.monthly: return (_datetime as Month).stop;
    }
  }

  void set(DateTime datetime) {
    switch(view) {
      case CalendarView.daily:    _datetime = datetime.date;
      case CalendarView.weekly:   _datetime = datetime.toWeek;
      case CalendarView.monthly:  _datetime = datetime.toMonth;
    }
    notifyListeners();
  }

  void next([bool swiping = false]) {
    _datetime = (_datetime as dynamic) + 1;
    if (swiping) return swipe(CalendarSwipe.forward);
    notifyListeners();
  }

  void last([bool swiping = false]) {
    _datetime = (_datetime as dynamic) - 1;
    if (swiping) return swipe(CalendarSwipe.backward);
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
    final header = CalendarConfig.of(context).header;
    switch (view) {
      case CalendarView.weekly:
        final week = asWeek;
        return "${week.mon.format(header.format)}"
            " ─ ${week.sun.format(header.format)}";
      default:
        return datetime.format(header.format);
    }
  }
}

class CalendarController extends ScrollController {
  final key = GlobalKey();
  late DateTime datetime;
  double distance = 0.0;

  @override
  void jumpTo(double value) {
    distance += value - position.pixels;
    super.jumpTo(value);
  }
}