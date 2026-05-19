import 'package:flutter/foundation.dart';
import '../utils/datetime.dart';


class Fixture with Diagnosticable {

  Fixture({
    required this.start,
    DateTime? stop,
  }) : stop = stop ?? start.date + 1;

  Map<String, dynamic> get() => {
    "start": start,
    "stop": stop,
  };

  Fixture set(Map<String, dynamic> data) {
    if (data.containsKey("start")) start = data["start"] as DateTime;
    if (data.containsKey("stop")) stop = data["stop"] as DateTime;
    return this;
  }

  DateTime start;
  DateTime stop;
  Duration get duration => stop.difference(start);
  bool get isAllDay => start == start.date && stop == stop.date;
  bool get isSpanned => duration.inDays >= 1 && stop != start.date + 1;


  @override
  int get hashCode => Object.hash(start, stop);

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