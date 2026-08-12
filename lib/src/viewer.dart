import 'package:flutter/material.dart';
import 'utils/datetime.dart';
import 'source.dart';
import 'config.dart';
import 'enums.dart';


class CalendarViewer extends ChangeNotifier {

  final CalendarView view;
  final CalendarEvents source;
  final CalendarController controller;
  late DateTime _datetime;
  CalendarSwipe? _swiping;

  CalendarViewer(this.source, {
    required this.view,
    required CalendarScroll scroll,
  }) : controller = CalendarController(scroll) {
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

  dynamic type(dynamic datetime) => switch(view) {
    CalendarView.daily =>   (datetime as Date),
    CalendarView.weekly =>  (datetime as Week),
    CalendarView.monthly => (datetime as Month),
  };

  Date get start => switch(view) {
    CalendarView.daily =>   type(_datetime).start,
    CalendarView.weekly =>  type(_datetime).start,
    CalendarView.monthly => type(_datetime).start,
  };

  Date get stop => switch(view) {
    CalendarView.daily =>   type(_datetime).stop,
    CalendarView.weekly =>  type(_datetime).stop,
    CalendarView.monthly => type(_datetime).stop,
  };

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
        return "${week.mon.format(header.format ?? "dd/mm/yyyy")}"
            " ─ ${week.sun.format(header.format ?? "dd/mm/yyyy")}";
      default:
        return datetime.format(header.format);
    }
  }
}

class CalendarController extends ScrollController {
  final CalendarScroll scroll;
  final key = GlobalKey();
  late DateTime datetime;
  double distance = 0.0;

  CalendarController(this.scroll);

  @override
  void jumpTo(double value) {
    distance += value - position.pixels;
    super.jumpTo(value);
  }
}