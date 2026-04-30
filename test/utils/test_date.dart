import 'package:intl/intl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final now = DateTime.now();
  final today = Date.now();
  final year = today.year;
  final month = today.month;
  final day = today.day;

  group('Date', () {
    test('Date now', () {
      expect(today, isA<Date>());
      expect(today.year, now.year);
      expect(today.month, now.month);
      expect(today.day, now.day);
    });

    test('Date constructor', () {
      final date = Date(year, month, day);
      expect(date, isA<DateTime>());
      expect(date.year, year);
      expect(date.month, month);
      expect(date.day, day);
    });

    test('Date from DateTime constructor', () {
      final date = now.toDate;
      expect(date, isA<Date>());
      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
    });

    test('Date as DateTime constructor', () {
      final datetime = today as DateTime;
      expect(datetime, isA<DateTime>());
      expect(datetime.year, today.year);
      expect(datetime.month, today.month);
      expect(datetime.day, today.day);
    });

    test('Date toString', () {
      final date = Date(year, month, day);
      final string = DateFormat("yyyy-MM-dd").format(now);
      expect(date.toString(), string.split(' ')[0]);
    });

    test('Date fromString', () {
      final string = now.toString();
      final date = Date.fromString(string.split(' ')[0]);
      expect(date.year, year);
      expect(date.month, month);
      expect(date.day, day);
    });

    test('Date operator ==', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today == now, true);
      expect(today == tomorrow, false);
      expect(today == yesterday, false);
    });

    test('Date operator <', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today < now, false);
      expect(today < tomorrow, true);
      expect(today < yesterday, false);
    });

    test('Date operator <=', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today <= today, true);
      expect(today <= tomorrow, true);
      expect(today < yesterday, false);
    });

    test('Date operator >', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today > now, false);
      expect(today > tomorrow, false);
      expect(today > yesterday, true);
    });

    test('Date operator >=', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today >= now, true);
      expect(today >= tomorrow, false);
      expect(today >= yesterday, true);
    });

    test('Date operator +', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today + 1 == tomorrow, true);
      expect(today + -1 == yesterday, true);
      final monthDays = today.toMonth.days;
      final afterMonth = now.add(Duration(days: monthDays));
      final beforeMonth = now.add(Duration(days: -monthDays));
      expect(today + monthDays == afterMonth, true);
      expect(today + -monthDays == beforeMonth, true);
      expect(today.month + 1, afterMonth.month);
      expect(today.month - 1, beforeMonth.month);
    });

    test('Date operator -', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today - 1 == yesterday, true);
      expect(today - -1 == tomorrow, true);
      final monthDays = today.toMonth.days;
      final afterMonth = now.add(Duration(days: monthDays));
      final beforeMonth = now.add(Duration(days: -monthDays));
      expect(today - -monthDays == afterMonth, true);
      expect(today - monthDays == beforeMonth, true);
      expect(today.month + 1, afterMonth.month);
      expect(today.month - 1, beforeMonth.month);
    });

    test('Date operator %', () {
      final tomorrow = now.add(Duration(days: 1));
      final yesterday = now.add(Duration(days: -1));
      expect(today % tomorrow == -1, true);
      expect(today % yesterday == 1, true);
    });
  });
}