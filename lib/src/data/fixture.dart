import 'package:flutter/foundation.dart';
import '../utils/datetime.dart';


class Fixture with Diagnosticable {

  Fixture({
    required this.start,
    DateTime? stop,
  }) : stop = stop ?? start.dayEnd;

  DateTime start;
  DateTime stop;
  Duration get duration => stop.difference(start);
  bool get isAllDay => start == start.dayBeg && stop == stop.dayBeg;
  bool get isSpanned => duration.inDays >= 1 && stop != start.dayEnd;


  @override
  int get hashCode {
    return Object.hash(start, stop);
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is Fixture) {
      return other.start == start &&
          other.stop == stop;
    }
    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('start', start));
    properties.add(DiagnosticsProperty<DateTime>('stop', stop));
  }
}