import 'package:flutter/material.dart';
import 'enums.dart';


class CalendarScroller extends ScrollController {
  final GlobalKey key = GlobalKey();
  final CalendarScroll scroll;
  late DateTime datetime;
  double distance = 0.0;

  CalendarScroller(this.scroll);

  @override
  void jumpTo(double value) {
    distance += value - position.pixels;
    super.jumpTo(value);
  }
}