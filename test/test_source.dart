import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  group('CalendarSource.forDate — days overlap', () {
    final today = Date.now();
    final yesterday = today - 1;
    final tomorrow = today + 1;

    test('reading today an event started yesterday', () {
      final event = Event(
        start: yesterday & Time(22, 0),
        stop: today & Time(2, 0),
        color: Colors.blue,
        subject: 'Started yesterday',
      );
      final source = CalendarSource([event]);
      final result = source.forDate(today);
      expect(result, contains(event));
    },);

    test('reading today an event finished tomorrow', () {
      final event = Event(
        start: today & Time(22, 0),
        stop: tomorrow & Time(2, 0),
        color: Colors.blue,
        subject: 'Finished tomorrow',
      );
      final source = CalendarSource([event]);
      final result = source.forDate(today);
      expect(result, contains(event));
    },);

    test('reading today an event started the day before yesterday', () {
      final event = Event(
        start: (yesterday - 1) & Time(22, 0),
        stop: today & Time(2, 0),
        color: Colors.blue,
        subject: 'Started yesterday',
      );
      final source = CalendarSource([event]);
      final result = source.forDate(today);
      expect(result, contains(event));
    },);

    test('reading today an event finished the day after tomorrow', () {
      final event = Event(
        start: today & Time(22, 0),
        stop: (tomorrow + 1) & Time(2, 0),
        color: Colors.blue,
        subject: 'Finished after tomorrow',
      );
      final source = CalendarSource([event]);
      final result = source.forDate(today);
      expect(result, contains(event));
    },);

    test('reading today an event started yesterday and finished tomorrow', () {
      final event = Event(
        start: yesterday & Time(22, 0),
        stop: tomorrow & Time(2, 0),
        color: Colors.blue,
        subject: 'Started yesterday and Finished tomorrow',
      );
      final source = CalendarSource([event]);
      final result = source.forDate(today);
      expect(result, contains(event));
    },);

    test('reading today an event finished yesterday', () {
      final event = Event(
        start: yesterday & Time(22, 0),
        stop: yesterday & Time(23, 59),
        color: Colors.blue,
        subject: 'Finished yesterday',
      );
      final source = CalendarSource([event]);
      final result = source.forDate(today);
      expect(result, isNot(contains(event)));
    },);

    test('reading today an event started tomorrow', () {
      final event = Event(
        start: tomorrow,
        stop: tomorrow & Time(2, 0),
        color: Colors.blue,
        subject: 'Started tomorrow',
      );
      final source = CalendarSource([event]);
      final result = source.forDate(today);
      expect(result, isNot(contains(event)));
    },);

    test('cache persistency', () {
        final event = Event(
          start: yesterday & Time(22, 0),
          stop: today & Time(2, 0),
          color: Colors.purple,
          subject: '',
        );
        final source = CalendarSource([event]);
        final first = source.forDate(today);
        final second = source.forDate(today);
        expect(first, contains(event));
        expect(second, contains(event));
    },);
  });
}