import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'enums.dart';


class CalendarController extends ChangeNotifier {

  final CalendarView view;
  late DateTime _datetime;
  CalendarSwipe? _swipe;

  CalendarController(this.view) {
    switch (view) {
      case CalendarView.daily:   _datetime = Date.now();
      case CalendarView.weekly:  _datetime = Week.now();
      case CalendarView.monthly: _datetime = Month.now();
    }
  }

  // Getter tipizzati — il cast è in un posto solo
  Date  get asDate  => _datetime.date;
  Week  get asWeek  => _datetime.toWeek;
  Month get asMonth => _datetime.toMonth;

  // Mantenuto per retrocompatibilità
  DateTime get datetime => _datetime;
  CalendarSwipe? get swipe => _swipe;

  void next([bool animate = true]) {
    _datetime = (_datetime as dynamic) + 1;
    _swipe = animate ? CalendarSwipe.forward : null;
    notifyListeners();
  }

  void last([bool animate = true]) {
    _datetime = (_datetime as dynamic) - 1;
    _swipe = animate ? CalendarSwipe.backward : null;
    notifyListeners();
  }

  void clear() {
    _swipe = null;
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
