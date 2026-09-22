import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/pattern.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {

  final id = "eventId";
  final start = DateTime.now();
  final stop = start.add(Duration(hours: 1));
  final color = Color(0x00000000);
  final subject = "event";
  final location = "location";
  final parentId = "parentId";
  final pattern = Pattern(
    type: PatternType.weekly,
  );

  final data = {
    "subject": subject,
    "start": start,
    "stop": stop,
    "color": color,
    "location": location,
    "parentId": parentId,
    "pattern": pattern,
  };

  final occurrence = Event(
    id: "occurrenceId",
    start: start,
    stop: stop,
    subject: "occurrence",
    location: location,
    color: color
  );
  final recurrence = Event(
    id: "recurrenceId",
    start: start,
    stop: stop,
    subject: "recurrence",
    location: location,
    color: color,
    pattern: pattern,
  );
  final deviation = Event(
    id: "deviationId",
    start: start,
    stop: stop,
    subject: "deviation",
    location: location,
    color: color,
    pattern: pattern,
    parentId: "recurrenceId"
  );
  final exception = Event(
      id: "exceptionId",
      start: start,
      stop: stop,
      subject: "deviation",
      location: location,
      color: color,
      parentId: "recurrenceId"
  );
  final instance = Event(
      start: start,
      stop: stop,
      subject: "deviation",
      location: location,
      color: color,
      pattern: pattern,
      parentId: "recurrenceId"
  );
  // final exemplar = Event(
  //     start: start,
  //     stop: stop,
  //     subject: "exemplar",
  //     location: location,
  //     color: color,
  // );


  group('Event', () {
    test('Event constructor default', () {
      final event = Event(
        subject: subject,
        start: start,
        stop: stop,
        color: color,
      );
      expect(event.id, isNull);
      expect(event.subject, subject);
      expect(event.start, start);
      expect(event.stop, stop);
      expect(event.color, color);
      expect(event.location, isNull);
      expect(event.parentId, isNull);
      expect(event.pattern, isNull);
    });

    test('Event constructor ', () {
      final event = Event(
        id: id,
        subject: subject,
        start: start,
        stop: stop,
        color: color,
        location: location,
        parentId: parentId,
        pattern: pattern,
      );
      expect(event.id, id);
      expect(event.subject, subject);
      expect(event.start, start);
      expect(event.stop, stop);
      expect(event.color, color);
      expect(event.location, location);
      expect(event.parentId, parentId);
      expect(event.pattern, pattern);
    });

    test('Event make', () {
      final event = Event.make(data: data);
      expect(event.id, isNull);
      expect(event.subject, subject);
      expect(event.start, start);
      expect(event.stop, stop);
      expect(event.color, color);
      expect(event.location, location);
      expect(event.parentId, parentId);
      expect(event.pattern, pattern);
    });

    test('Event make with id', () {
      final event = Event.make(id: id, data: data);
      expect(event.id, id);
      expect(event.subject, subject);
      expect(event.start, start);
      expect(event.stop, stop);
      expect(event.color, color);
      expect(event.location, location);
      expect(event.parentId, parentId);
      expect(event.pattern, pattern);
    });

    test('Event get', () {
      final event = Event.make(data: data);
      final result = event.get();
      expect(result, isA<Map<String, dynamic>>());
      expect(result["id"], event.id);
      expect(result["subject"], event.subject);
      expect(result["start"], event.start);
      expect(result["stop"], event.stop);
      expect(result["color"], event.color);
      expect(result["location"], event.location);
      expect(result["parentId"], event.parentId);
      expect(result["pattern"], event.pattern);
    });

    test('Event set', () {
      final event = Event(
        subject: "",
        start: DateTime(1),
        color: Color(0xFFFFFFFF),
      );
      final result = event.set(data);
      expect(identical(result, event), isFalse);
      expect(result, isA<Event>());
      expect(result.id, isNull);
      expect(result.subject, data["subject"]);
      expect(result.start, data["start"]);
      expect(result.stop, data["stop"]);
      expect(result.color, data["color"]);
      expect(result.location, data["location"]);
      expect(result.parentId, isNull);
      expect(result.pattern, isNull);
    });

    test('hashCode', () {
      final event = Event.make(data: data);
      final eventWithId = Event.make(id: id, data: data);
      expect(event.hashCode, equals(eventWithId.hashCode));
    });

    test('operator ==', () {
      final event = Event.make(data: data);
      final eventWithId = Event.make(id: id, data: data);
      expect(event, equals(eventWithId));
    });

    test('extend Fixture (isAllDay)', () {
      final allDay = Event(
        subject: subject,
        start: start.date,
        color: color,
      );
      expect(allDay.start, start.date);
      expect(allDay.stop, start.tomorrow);
      expect(allDay.duration, Duration(days: 1));
      expect(allDay.isAllDay, true);
      expect(allDay.isSpanned, false);
    });

    test('extend Fixture (isSpanned)', () {
      final days = 3;
      final spanDay = Event(
        subject: subject,
        start: start.date,
        stop: start.date + days,
        color: color,
      );
      expect(spanDay.start, start.date);
      expect(spanDay.stop, start.date + days);
      expect(spanDay.duration, Duration(days: days));
      expect(spanDay.isAllDay, true);
      expect(spanDay.isSpanned, true);
    });
  });


  group('Event Types', () {

    test('Event type', () {
      expect(occurrence.type, EventType.occurrence);
      expect(recurrence.type, EventType.recurrence);
      expect(deviation.type, EventType.deviation);
      expect(exception.type, EventType.exception);
      expect(instance.type, EventType.instance);
    });

    test('Event isOccurrence', () {
      expect(occurrence.isOccurrence, isTrue);
      expect(recurrence.isOccurrence, isFalse);
      expect(deviation.isOccurrence, isFalse);
      expect(exception.isOccurrence, isFalse);
      expect(instance.isOccurrence, isFalse);
    });

    test('Event isRecurrence', () {
      expect(occurrence.isRecurrence, isFalse);
      expect(recurrence.isRecurrence, isTrue);
      expect(deviation.isRecurrence, isFalse);
      expect(exception.isRecurrence, isFalse);
      expect(instance.isRecurrence, isFalse);
    });

    test('Event isDeviation', () {
      expect(occurrence.isDeviation, isFalse);
      expect(recurrence.isDeviation, isFalse);
      expect(deviation.isDeviation, isTrue);
      expect(exception.isDeviation, isFalse);
      expect(instance.isDeviation, isFalse);
    });

    test('Event isException', () {
      expect(occurrence.isException, isFalse);
      expect(recurrence.isException, isFalse);
      expect(deviation.isException, isFalse);
      expect(exception.isException, isTrue);
      expect(instance.isException, isFalse);
    });

    test('Event isInstance', () {
      expect(occurrence.isInstance, isFalse);
      expect(recurrence.isInstance, isFalse);
      expect(deviation.isInstance, isFalse);
      expect(exception.isInstance, isFalse);
      expect(instance.isInstance, isTrue);
    });

  });

}