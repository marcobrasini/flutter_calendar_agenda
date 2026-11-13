import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../utils/datetime.dart';

class Fixture extends Equatable {
  final DateTime start;
  final DateTime stop;

  Fixture({required this.start, DateTime? stop})
    : stop = stop ?? start.date + 1;

  Map<String, dynamic> get() => {"start": start, "stop": stop};

  @useResult
  Fixture set(Map<String, dynamic> data) =>
      Fixture(start: data['start'] ?? start, stop: data['stop'] ?? stop);

  @useResult
  Fixture copyWith({DateTime? start, DateTime? stop}) =>
      Fixture(start: start ?? this.start, stop: stop ?? this.stop);

  Duration get duration => stop.difference(start);
  bool get isAllDay => start == start.date && stop == stop.date;
  bool get isMoreDay => last != first;
  bool get isMultiDay => isAllDay || isMoreDay;

  Date get first => start.date;
  Date get last => stop.isAfter(start) && stop == stop.date
      ? stop.date - 1
      : stop.date;

  List<Date> get dates => [
    for (var d = first; d <= last; d += 1) d,
  ];

  bool spans(DateTime? from, DateTime? to) =>
      (to == null || start.isBefore(to)) &&
      (from == null || stop.isAfter(from));

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [start, stop];
}
