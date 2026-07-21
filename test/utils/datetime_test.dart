import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final now = DateTime.now();

  group('DateTime', () {

    test('toYear', () {
      final year = now.toYear;
      expect(year, isA<Year>());
      expect(year.year, now.year);
    });

    test('toMonth', () {
      final month = now.toMonth;
      expect(month, isA<Month>());
      expect(month.year, now.year);
      expect(month.month, now.month);
    });

    test('toWeek', () {
      final date = now.weekStart;
      final week = now.toWeek;
      expect(week, isA<Week>());
      expect(week.year, date.year);
      expect(week.month, date.month);
      expect(week.day, date.day);
    });

    test('toDate', () {
      final date = now.date;
      expect(date, isA<Date>());
      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
    });

    test('toTime', () {
      final time = now.time;
      expect(time, isA<Time>());
      expect(time.hour, now.hour);
      expect(time.minute, now.minute);
    });

    test('toISOString local', () {
      final isoString = now.toString().split('.')[0].split(" ");
      expect(now.toISOString(), ""
          "${isoString[0].replaceAll('-', '')}T"
          "${isoString[1].replaceAll(':', '')}");
    });

    test('toISOString UTC', () {
      final isoString = now.toUtc().toString().split('.')[0].split(" ");
      expect(now.toUtc().toISOString(), ""
          "${isoString[0].replaceAll('-', '')}T"
          "${isoString[1].replaceAll(':', '')}Z");
    });

    test('isLeapYear', () {
      expect(DateTime(1600).isLeapYear, isTrue);
      expect(DateTime(1700).isLeapYear, isFalse);
      expect(DateTime(1800).isLeapYear, isFalse);
      expect(DateTime(1900).isLeapYear, isFalse);
      expect(DateTime(2000).isLeapYear, isTrue);
      expect(DateTime(2020).isLeapYear, isTrue);
      expect(DateTime(2021).isLeapYear, isFalse);
      expect(DateTime(2022).isLeapYear, isFalse);
      expect(DateTime(2023).isLeapYear, isFalse);
      expect(DateTime(2024).isLeapYear, isTrue);
      expect(DateTime(2025).isLeapYear, isFalse);
      expect(DateTime(2026).isLeapYear, isFalse);
      expect(DateTime(2027).isLeapYear, isFalse);
      expect(DateTime(2028).isLeapYear, isTrue);
      expect(DateTime(2029).isLeapYear, isFalse);
      expect(DateTime(2030).isLeapYear, isFalse);
      expect(DateTime(2031).isLeapYear, isFalse);
      expect(DateTime(2032).isLeapYear, isTrue);
      expect(DateTime(2100).isLeapYear, isFalse);
    });

    test('dayNumber', () {
      expect(DateTime(2000,  1,  1).dayNumber, 0);
      expect(DateTime(2000,  1, 31).dayNumber, 31-1);
      expect(DateTime(2000,  2,  1).dayNumber, 31+0);
      expect(DateTime(2000,  2, 28).dayNumber, 31+28-1);
      expect(DateTime(2000,  2, 29).dayNumber, 31+28);
      expect(DateTime(2000,  3,  1).dayNumber, 31+28+1+0);
      expect(DateTime(2000,  3, 31).dayNumber, 31+28+1+31-1);
      expect(DateTime(2000,  4,  1).dayNumber, 31+28+1+31+0);
      expect(DateTime(2000,  4, 30).dayNumber, 31+28+1+31+30-1);
      expect(DateTime(2000,  5,  1).dayNumber, 31+28+1+31+30+0);
      expect(DateTime(2000,  5, 31).dayNumber, 31+28+1+31+30+31-1);
      expect(DateTime(2000,  6,  1).dayNumber, 31+28+1+31+30+31+0);
      expect(DateTime(2000, 12, 31).dayNumber, 366-1);
      expect(DateTime(2001,  1,  1).dayNumber, 0);
      expect(DateTime(2001,  1, 31).dayNumber, 31-1);
      expect(DateTime(2001,  2,  1).dayNumber, 31+0);
      expect(DateTime(2001,  2, 28).dayNumber, 31+28-1);
      expect(DateTime(2001,  3,  1).dayNumber, 31+28+0);
      expect(DateTime(2001,  3, 31).dayNumber, 31+28+31-1);
      expect(DateTime(2001,  4,  1).dayNumber, 31+28+31+0);
      expect(DateTime(2001,  4, 30).dayNumber, 31+28+31+30-1);
      expect(DateTime(2001,  5,  1).dayNumber, 31+28+31+30+0);
      expect(DateTime(2001,  5, 31).dayNumber, 31+28+31+30+31-1);
      expect(DateTime(2001,  6,  1).dayNumber, 31+28+31+30+31+0);
      expect(DateTime(2001, 12, 31).dayNumber, 365-1);
    });

    test('weekStart', () {
      final weekStart = now.weekStart;
      expect(weekStart, isA<DateTime>());
      expect(weekStart.weekday, DateTime.monday);
      expect(weekStart.hour, 0);
      expect(weekStart.minute, 0);
      expect(weekStart.second, 0);
    });

    // test('weekLast', () {
    //   final weekLast = now.weekLast;
    //   expect(weekLast, isA<DateTime>());
    //   expect(weekLast.weekday, DateTime.sunday);
    //   expect(weekLast.hour, 0);
    //   expect(weekLast.minute, 0);
    //   expect(weekLast.second, 0);
    // });

    test('weekEnd', () {
      final weekEnd = now.weekEnd;
      expect(weekEnd, isA<DateTime>());
      expect(weekEnd.weekday, DateTime.monday);
      expect(weekEnd.hour, 0);
      expect(weekEnd.minute, 0);
      expect(weekEnd.second, 0);
    });

    test('monthStart', () {
      final monthStart = now.monthStart;
      expect(monthStart, isA<DateTime>());
      expect(monthStart.year, now.year);
      expect(monthStart.month, now.month);
      expect(monthStart.day, 1);
      expect(monthStart.hour, 0);
      expect(monthStart.minute, 0);
      expect(monthStart.second, 0);
    });

    // test('monthLast', () {
    //   final date = now.toMonth;
    //   final monthLast = now.monthLast;
    //   expect(monthLast, isA<DateTime>());
    //   expect(monthLast.year, now.year);
    //   expect(monthLast.month, now.month);
    //   expect(monthLast.day, date.days);
    //   expect(monthLast.hour, 0);
    //   expect(monthLast.minute, 0);
    //   expect(monthLast.second, 0);
    // });

    test('monthEnd', () {
      final monthEnd = now.monthEnd;
      expect(monthEnd, isA<DateTime>());
      expect(monthEnd.year, now.year);
      expect(monthEnd.month, now.month + 1);
      expect(monthEnd.day, 1);
      expect(monthEnd.hour, 0);
      expect(monthEnd.minute, 0);
      expect(monthEnd.second, 0);
    });

    test('yearStart', () {
      final yearStart = now.yearStart;
      expect(yearStart, isA<DateTime>());
      expect(yearStart.year, now.year);
      expect(yearStart.month, 1);
      expect(yearStart.day, 1);
      expect(yearStart.hour, 0);
      expect(yearStart.minute, 0);
      expect(yearStart.second, 0);
    });

    // test('yearLast', () {
    //   final yearLast = now.yearLast;
    //   expect(yearLast, isA<DateTime>());
    //   expect(yearLast.year, now.year);
    //   expect(yearLast.month, 12);
    //   expect(yearLast.day, 31);
    //   expect(yearLast.hour, 0);
    //   expect(yearLast.minute, 0);
    //   expect(yearLast.second, 0);
    // });

    test('yearEnd', () {
      final yearEnd = now.yearEnd;
      expect(yearEnd, isA<DateTime>());
      expect(yearEnd.year, now.year + 1);
      expect(yearEnd.month, 1);
      expect(yearEnd.day, 1);
      expect(yearEnd.hour, 0);
      expect(yearEnd.minute, 0);
      expect(yearEnd.second, 0);
    });

  });
}
