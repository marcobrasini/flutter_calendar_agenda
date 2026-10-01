import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import 'scroller.dart';
import 'parser.dart';
import 'enums.dart';


class CalendarViewer extends ChangeNotifier with CalendarParser {
  @override final CalendarView view;
  final CalendarScroller scroller;

  CalendarViewer({
    required this.view,
    required CalendarScroll scroll,
  }) : scroller = CalendarScroller(scroll) {
    datetime = DateTime.now();
    scroller.datetime = datetime;
  }

  bool _jumping = false;
  bool get jumping => _jumping;

  CalendarSwipe? _swiping;
  CalendarSwipe? get swiping => _swiping;

  void next([bool swiping = false]) {
    datetime = (datetime as dynamic) + 1;
    if (swiping) return swipe(CalendarSwipe.forward);
    notifyListeners();
  }

  void last([bool swiping = false]) {
    datetime = (datetime as dynamic) - 1;
    if (swiping) return swipe(CalendarSwipe.backward);
    notifyListeners();
  }

  void jump(DateTime target, {bool animate = true}) {
    final normalized = normalize(target);
    if (normalized == datetime) return;
    if (animate) {
      if (normalized == datetime + 1) return next(true);
      if (normalized == datetime - 1) return last(true);
    }
    datetime = normalized;
    _swiping = null;
    _jumping = true;
    notifyListeners();
  }

  void swipe(CalendarSwipe swipe) {
    _swiping = swipe;
    notifyListeners();
  }

  void clear() {
    _swiping = null;
    _jumping = false;
  }

  String title(BuildContext context) {
    final header = CalendarConfig.of(context).headerConfig(view);
    switch (view) {
      case CalendarView.weekly:
        final week = asWeek;
        return "${week.mon.format(header.format ?? "dd/mm/yyyy")}"
            " ─ ${week.sun.format(header.format ?? "dd/mm/yyyy")}";
      default:
        return datetime.format(header.format);
    }
  }

  @override
  void dispose() {
    scroller.dispose();
    super.dispose();
  }
}
