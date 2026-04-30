import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'fixture.dart';
import 'pattern.dart';


enum EventType {
  occurrence,
  recurrence,
  exception,
  deviation,
  instance,
  exemplar,
}


class Event extends Fixture with Diagnosticable {

  final String? id;
  String subject;
  Color color;
  String? location;
  String? parentId;
  Pattern? pattern;

  Event({
    this.id,
    required this.subject,
    required super.start,
    super.stop,
    required this.color,
    this.location,
    this.parentId,
    this.pattern,
  });

  factory Event.make({
    String? id,
    required Map<String, dynamic> data
  })  => Event(
    id: id,
    subject: data["subject"],
    start: data["start"],
    stop: data["stop"],
    color: data["color"],
    location: data["location"],
    parentId: data["parentId"],
    pattern: data["pattern"],
  );

  bool get isOccurrence => id != null && pattern==null && parentId == null;

  bool get isRecurrence => id != null && pattern!=null && parentId == null;

  bool get isException => id != null && pattern==null && parentId!=null;

  bool get isDeviation => id != null && pattern!=null && parentId!=null;

  bool get isInstance => id == null && pattern!=null;

  bool get isExemplar => id == null && pattern==null;

  EventType get type {
    if (isExemplar) return EventType.exemplar;
    if (isInstance) return EventType.instance;
    if (isDeviation) return EventType.deviation;
    if (isException) return EventType.exception;
    if (isRecurrence) return EventType.recurrence;
    if (isOccurrence) return EventType.occurrence;
    throw(StateError("undefined EventType."));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('id', id));
    properties.add(StringProperty('subject', subject));
    properties.add(ColorProperty('color', color));
    properties.add(StringProperty('location', location));
    properties.add(StringProperty('parentId', parentId));
    properties.add(DiagnosticsProperty<Object>('pattern', pattern));
  }
}