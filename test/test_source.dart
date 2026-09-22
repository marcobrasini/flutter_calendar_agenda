import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/pattern.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {

  group('CalendarSource tests', () {
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

  group('CalendarSource build tests', () {
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
    final cached = {
      yesterday: [
        events[2].instance({
          "start": yesterday & events[2].start.time,
          "stop": yesterday & events[2].stop.time,
        }),
      ],
      today: [
        events[0],
        events[2].instance({
          "start": today & events[2].start.time,
          "stop": today & events[2].stop.time,
        }),
      ],
      tomorrow: [
        events[2].instance({
          "start": tomorrow & events[2].start.time,
          "stop": tomorrow & events[2].stop.time,
        }),
        events[1],
      ],
      tomorrow + 1: [
        events[2].instance({
          "start": tomorrow + 1 & events[2].start.time,
          "stop": tomorrow + 1 & events[2].stop.time,
        }),
      ],
    };

    test('CalendarSource build', () {
      final source = CalendarEvents(events: events);
      source.load(yesterday, tomorrow + 1);
      expect(source.built, isTrue);
      expect(source.dates, [yesterday, today, tomorrow]);
    },);

    test('CalendarSource forDate', () {
      final source = CalendarEvents(events: events);
      source.load(yesterday, tomorrow + 1);
      for (var date in source.dates) {
        expect(source.forDate(date), cached[date]);
      }
    },);


    test('CalendarSource shift', () {
      final source = CalendarEvents(events: events);
      source.load(yesterday, tomorrow + 1);
      expect(source.dates, [yesterday, today, tomorrow]);
      for (var date in source.dates) {
        expect(source.forDate(date), cached[date]);
      }
      source.load(yesterday+1, tomorrow + 2);
      expect(source.dates, [today, tomorrow, tomorrow + 1]);
      for (var date in source.dates) {
        expect(source.forDate(date), cached[date]);
      }
    },);
  });

  // group('CalendarSource.forDate — days overlap', () {
  //   final today = Date.now();
  //   final yesterday = today - 1;
  //   final tomorrow = today + 1;
  //
  //   test('reading today an event started yesterday', () {
  //     final event = Event(
  //       start: yesterday & Time(22, 0),
  //       stop: today & Time(2, 0),
  //       color: Colors.blue,
  //       subject: 'Started yesterday',
  //     );
  //     final source = CalendarEvents(events: [event]);
  //     final result = source.forDate(today);
  //     expect(result, contains(event));
  //   },);
  //
  //   test('reading today an event finished tomorrow', () {
  //     final event = Event(
  //       start: today & Time(22, 0),
  //       stop: tomorrow & Time(2, 0),
  //       color: Colors.blue,
  //       subject: 'Finished tomorrow',
  //     );
  //     final source = CalendarEvents(events: [event]);
  //     final result = source.forDate(today);
  //     expect(result, contains(event));
  //   },);
  //
  //   test('reading today an event started the day before yesterday', () {
  //     final event = Event(
  //       start: (yesterday - 1) & Time(22, 0),
  //       stop: today & Time(2, 0),
  //       color: Colors.blue,
  //       subject: 'Started yesterday',
  //     );
  //     final source = CalendarEvents(events: [event]);
  //     final result = source.forDate(today);
  //     expect(result, contains(event));
  //   },);
  //
  //   test('reading today an event finished the day after tomorrow', () {
  //     final event = Event(
  //       start: today & Time(22, 0),
  //       stop: (tomorrow + 1) & Time(2, 0),
  //       color: Colors.blue,
  //       subject: 'Finished after tomorrow',
  //     );
  //     final source = CalendarEvents(events: [event]);
  //     final result = source.forDate(today);
  //     expect(result, contains(event));
  //   },);
  //
  //   test('reading today an event started yesterday and finished tomorrow', () {
  //     final event = Event(
  //       start: yesterday & Time(22, 0),
  //       stop: tomorrow & Time(2, 0),
  //       color: Colors.blue,
  //       subject: 'Started yesterday and Finished tomorrow',
  //     );
  //     final source = CalendarEvents(events: [event]);
  //     final result = source.forDate(today);
  //     expect(result, contains(event));
  //   },);
  //
  //   test('reading today an event finished yesterday', () {
  //     final event = Event(
  //       start: yesterday & Time(22, 0),
  //       stop: yesterday & Time(23, 59),
  //       color: Colors.blue,
  //       subject: 'Finished yesterday',
  //     );
  //     final source = CalendarEvents(events: [event]);
  //     final result = source.forDate(today);
  //     expect(result, isNot(contains(event)));
  //   },);
  //
  //   test('reading today an event started tomorrow', () {
  //     final event = Event(
  //       start: tomorrow,
  //       stop: tomorrow & Time(2, 0),
  //       color: Colors.blue,
  //       subject: 'Started tomorrow',
  //     );
  //     final source = CalendarEvents(events: [event]);
  //     final result = source.forDate(today);
  //     expect(result, isNot(contains(event)));
  //   },);
  //
  //   test('cache persistency', () {
  //       final event = Event(
  //         start: yesterday & Time(22, 0),
  //         stop: today & Time(2, 0),
  //         color: Colors.purple,
  //         subject: '',
  //       );
  //       final source = CalendarEvents(events: [event]);
  //       final first = source.forDate(today);
  //       final second = source.forDate(today);
  //       expect(first, contains(event));
  //       expect(second, contains(event));
  //   },);
  // });
}