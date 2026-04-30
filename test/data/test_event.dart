import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/pattern.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {

  final start = DateTime.now();
  final stop = start.add(Duration(hours: 1));
  final color = Colors.blue;
  final eventId = "eventId";
  final subject = "event";
  final location = "location";
  final parentId = "parentId";
  final pattern = Pattern(
    type: PatternType.weekly,
    since: start
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
      id: "exception",
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
      pattern: pattern
  );
  final exemplar = Event(
      start: start,
      stop: stop,
      subject: "exemplar",
      location: location,
      color: color,
  );


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
        id: eventId,
        subject: subject,
        start: start,
        stop: stop,
        color: color,
        location: location,
        parentId: parentId,
        pattern: pattern,
      );
      expect(event.id, eventId);
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
      final event = Event.make(id: eventId, data: data);
      expect(event.id, eventId);
      expect(event.subject, subject);
      expect(event.start, start);
      expect(event.stop, stop);
      expect(event.color, color);
      expect(event.location, location);
      expect(event.parentId, parentId);
      expect(event.pattern, pattern);
    });

    test('extension from Fixture (isAllDay)', () {
      final allDay = Event(
        subject: subject,
        start: start.dayBeg,
        color: color,
      );
      expect(allDay.start, start.dayBeg);
      expect(allDay.stop, start.dayEnd);
      expect(allDay.duration, Duration(days: 1));
      expect(allDay.isAllDay, true);
      expect(allDay.isSpanned, false);
    });

    test('extension from Fixture (isSpanned)', () {
      final days = 3;
      final spanDay = Event(
        subject: subject,
        start: start.dayBeg,
        stop: start.toDate + days,
        color: color,
      );
      expect(spanDay.start, start.dayBeg);
      expect(spanDay.stop, start.toDate + days);
      expect(spanDay.duration, Duration(days: days));
      expect(spanDay.isAllDay, true);
      expect(spanDay.isSpanned, true);
    });
  });


  group('Event Type', () {

    test('Event type', () {
      expect(occurrence.type, EventType.occurrence);
      expect(recurrence.type, EventType.recurrence);
      expect(deviation.type, EventType.deviation);
      expect(exception.type, EventType.exception);
      expect(instance.type, EventType.instance);
      expect(exemplar.type, EventType.exemplar);
    });

    test('Event isOccurrence', () {
      expect(occurrence.isOccurrence, isTrue);
      expect(recurrence.isOccurrence, isFalse);
      expect(deviation.isOccurrence, isFalse);
      expect(exception.isOccurrence, isFalse);
      expect(instance.isOccurrence, isFalse);
      expect(exemplar.isOccurrence, isFalse);
    });

    test('Event isRecurrence', () {
      expect(occurrence.isRecurrence, isFalse);
      expect(recurrence.isRecurrence, isTrue);
      expect(deviation.isRecurrence, isFalse);
      expect(exception.isRecurrence, isFalse);
      expect(instance.isRecurrence, isFalse);
      expect(exemplar.isRecurrence, isFalse);
    });

    test('Event isDeviation', () {
      expect(occurrence.isDeviation, isFalse);
      expect(recurrence.isDeviation, isFalse);
      expect(deviation.isDeviation, isTrue);
      expect(exception.isDeviation, isFalse);
      expect(instance.isDeviation, isFalse);
      expect(exemplar.isDeviation, isFalse);
    });

    test('Event isException', () {
      expect(occurrence.isException, isFalse);
      expect(recurrence.isException, isFalse);
      expect(deviation.isException, isFalse);
      expect(exception.isException, isTrue);
      expect(instance.isException, isFalse);
      expect(exemplar.isException, isFalse);
    });

    test('Event isInstance', () {
      expect(occurrence.isInstance, isFalse);
      expect(recurrence.isInstance, isFalse);
      expect(deviation.isInstance, isFalse);
      expect(exception.isInstance, isFalse);
      expect(instance.isInstance, isTrue);
      expect(exemplar.isInstance, isFalse);
    });

    test('Event isExemplar', () {
      expect(occurrence.isExemplar, isFalse);
      expect(recurrence.isExemplar, isFalse);
      expect(deviation.isExemplar, isFalse);
      expect(exception.isExemplar, isFalse);
      expect(instance.isExemplar, isFalse);
      expect(exemplar.isExemplar, isTrue);
    });
  });


  group('Debug Properties', () {
    test('debugFillProperties', () {
      final event = Event(
        id: eventId,
        subject: subject,
        start: start,
        stop: stop,
        color: color,
        location: location,
        parentId: parentId,
        pattern: pattern,
      );
      final builder = DiagnosticPropertiesBuilder();
      event.debugFillProperties(builder);
      expect(builder.properties, isNotEmpty);
    });
  });
}