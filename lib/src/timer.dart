import 'package:flutter/material.dart';


class CalendarTimer extends ChangeNotifier {
  double scroll = 0.0;

  void swipe(double scrolling) {
    scroll = scrolling;
    notifyListeners();
  }
}