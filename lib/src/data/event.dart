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
  Color color;
  String subject;
  String? location;
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

  factory Event.make({
    String? id,
    required Map<String, dynamic> data
  })  => Event(
    id: id,
    start: data["start"],
    stop: data["stop"],
    color: data["color"],
    subject: data["subject"],
    location: data["location"],
    parentId: data["parentId"],
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
  Event set(Map<String, dynamic> data) {
    super.set(data);
    if (data.containsKey("color")) color = data["color"] as Color;
    if (data.containsKey("subject")) subject = data["subject"] as String;
    if (data.containsKey("location")) location = data["location"] as String?;
    return this;
  }

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
  int get hashCode => Object.hash(
      super.hashCode,
      color,
      subject,
      location,
      parentId,
      pattern.hashCode
  );

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is Event) {
      return other.start == start
          && other.stop == stop
          && other.color == color
          && other.subject == subject
          && other.location == location
          && other.parentId == parentId
          && other.pattern == pattern;
    }
    return false;
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