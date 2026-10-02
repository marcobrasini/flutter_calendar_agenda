import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../utils/datetime.dart';


class Fixture extends Equatable {
  final DateTime start;
  final DateTime stop;

  Fixture({
    required this.start,
    DateTime? stop,
  }) : stop = stop ?? start.date + 1;

  Map<String, dynamic> get() => {
    "start": start,
    "stop": stop,
  };

  @useResult
  Fixture set(Map<String, dynamic> data) => Fixture(
    start: data['start'] ?? start,
    stop: data['stop'] ?? stop,
  );

  @useResult
  Fixture copy() => Fixture(start: start, stop: stop);

  Duration get duration => stop.difference(start);
  bool get isAllDay => start == start.date && stop == stop.date;
  bool get isSpanned => duration.inDays >= 1 && stop != start.date + 1;

  // List<Date> get dates => [
  //   for (var date = start.date; date < stop.date + ((isAllDay) ? 1 : 0); date += 1)
  //     date,
  // ];

  List<Date> get dates {
    if (!stop.isAfter(start)) return [start.date];
    final last = stop.date + ((stop == stop.date) ? 0 : 1);
    return [
      for (var date = start.date; date < last; date += 1) date,
    ];
  }

  bool spans(DateTime? from, DateTime? to) =>
      (to == null || start.isBefore(to)) &&
      (from == null || stop.isAfter(from));

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [start, stop];
}
