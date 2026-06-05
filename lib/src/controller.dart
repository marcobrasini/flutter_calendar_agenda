import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'enums.dart';


class CalendarController extends ChangeNotifier {
  final CalendarView view;
  late dynamic _dateTime;

  CalendarController(this.view) {
    switch (view) {
      case CalendarView.daily:   _dateTime = Date.now();
      case CalendarView.weekly:  _dateTime = Week.now();
      case CalendarView.monthly: _dateTime = Month.now();
    }
  }

  dynamic get dateTime => _dateTime;

  String title(BuildContext context) {
    final header = CalendarConfig.of(context)!.header;
    switch (view) {
      case CalendarView.weekly:
        final start = dateTime.mon;
        final stop = dateTime.sun;
        return "${start.format(header.format)} ─ ${stop.format(header.format)}";
      default:
        return dateTime.format(header.format);
    }
  }

  void next() {
    _dateTime += 1;
    notifyListeners();
  }
  void last() {
    _dateTime -= 1;
    notifyListeners();
  }
}