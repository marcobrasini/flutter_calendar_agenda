import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/pattern.dart';


void main() {

  group('CalendarViewer tests', () {
    final today = Date.now();
    final yesterday = today - 1;
    final tomorrow = today + 1;
    final color = Colors.blue;
    final events = [
      Event(
        id: "occurrence1",
        start: today & Time(9, 0),
        stop: today & Time(10, 0),
        color: color,
        subject: 'Occurrence1',
      ),
      Event(
        id: "occurrence2",
        start: tomorrow & Time(13, 0),
        stop: tomorrow & Time(15, 0),
        color: color,
        subject: 'Occurrence2',
      ),
      Event(
        id: "recurrence1",
        start: yesterday & Time(11, 0),
        stop: yesterday & Time(12, 0),
        color: color,
        subject: 'Recurrence1',
        pattern: Pattern(type: PatternType.daily),
      )
    ];

    final source = CalendarEvents(events: events);

    test('CalendarSource constructor', () {
      final source = CalendarEvents(events: events);
      expect(source, isA<CalendarEvents>());
      expect(source.events, events);
      expect(source.built, isFalse);
    },);

    test('CalendarSource append', () {
      final source = CalendarEvents();
      source.set(events);
      expect(source.events, events);
      expect(source.built, isFalse);
    },);

    test('CalendarSource find', () {
      final source = CalendarEvents(events: events);
      for (int i = 0; i < events.length; i++) {
        expect(source.find(events[i].id!), events[i]);
      }
    },);

    test('CalendarSource dates empty', () {
      final source = CalendarEvents(events: events);
      expect(source.dates.isEmpty, isTrue);
      expect(source.built, isFalse);
    },);
  });

}