import 'dart:ui';
import 'package:meta/meta.dart';
import 'fixture.dart';
import 'pattern.dart';


enum EventType {
  occurrence,
  recurrence,
  exception,
  deviation,
  instance,
}


class Event extends Fixture {
  final String? id;
  final Color color;
  final String subject;
  final String? location;
  final String? parentId;
  final Pattern? pattern;

  Event({
    this.id,
    required super.start,
    super.stop,
    required this.color,
    required this.subject,
    this.location,
    this.parentId,
    this.pattern,
  });

  factory Event.make({String? id, required Map<String, dynamic> data}) => Event(
    id: id,
    start: data["start"] as DateTime,
    stop: data["stop"] as DateTime,
    color: data["color"] as Color,
    subject: data["subject"] as String,
    location: data["location"] as String?,
    parentId: data["parentId"] as String?,
    pattern: data["pattern"],
  );

  @override
  Map<String, dynamic> get() => {
    "id": id,
    ...super.get(),
    "color": color,
    "subject": subject,
    "location": location,
    "parentId": parentId,
    "pattern": pattern,
  };

  @override
  @useResult
  Event set(Map<String, dynamic> data) =>
      Event.make(id: id, data: {...get(), ...data});

  bool get isOccurrence => id != null && pattern == null && parentId == null;

  bool get isRecurrence => id != null && pattern != null && parentId == null;

  bool get isException => id != null && pattern == null && parentId != null;

  bool get isDeviation => id != null && pattern != null && parentId != null;

  bool get isInstance => id == null && pattern != null && parentId != null;

  bool get isLimited => pattern == null || pattern!.limited;

  bool owns(Event event) =>
      id != null &&
      (event.id == id || (event.isInstance && event.parentId == id));

  Event exemplar() => Event(
    start: start,
    stop: stop,
    color: color,
    subject: subject,
    location: location,
  );

  Event instance([Map<String, dynamic>? data]) =>
      Event.make(data: {...get(), ...(data ?? {}), "parentId": id});

  Event exception([String? id, Map<String, dynamic>? data]) => Event.make(
    id: id,
    data: {...get(), ...(data ?? {}), "pattern": null, "parentId": this.id},
  );

  Event deviation([String? id, Map<String, dynamic>? data]) => Event.make(
    id: id,
    data: {...get(), "pattern": pattern, ...(data ?? {}), "parentId": this.id},
  );

  EventType get type {
    if (isInstance) return EventType.instance;
    if (isDeviation) return EventType.deviation;
    if (isException) return EventType.exception;
    if (isRecurrence) return EventType.recurrence;
    if (isOccurrence) return EventType.occurrence;
    throw (StateError("undefined EventType."));
  }

  List<Event> expand(DateTime? from, DateTime? to) {
    if (pattern == null) return spans(from, to) ? [this] : [];
    if (from == null && to == null && !isLimited) return [];
    final instances = <Event>[];
    final iterator = pattern!.iterator(start);
    while (iterator.moveNext()) {
      final instanceStart = iterator.current;
      final instanceStop = instanceStart.add(duration);
      if (to != null && !instanceStart.isBefore(to)) break;
      if (from == null || instanceStop.isAfter(from)) {
        instances.add(instance({"start": instanceStart, "stop": instanceStop}));
      }
    }
    return instances;
  }

  @override
  List<Object?> get props => [
    id,
    ...super.props,
    color,
    subject,
    location,
    parentId,
    pattern,
  ];
}
