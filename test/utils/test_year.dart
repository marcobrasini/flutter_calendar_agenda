import 'package:intl/intl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final now = DateTime.now();
  final current = Year.now();

  bool isFirst(DateTime datetime) => datetime.date == datetime.yearStart;
  bool isLast(DateTime datetime) => datetime.date == datetime.yearLast;

  group('Year', () {

    test('Year now', () {
      expect(current, isA<Year>());
      expect(current.year, now.year);
    });

    test('Year from DateTime', () {
      final year = now.toYear;
      expect(year, isA<Year>());
      expect(year.year, now.year);
    });

    test('Year as DateTime', () {
      final datetime = current as DateTime;
      expect(datetime, isA<DateTime>());
      expect(datetime.year, now.year);
      expect(datetime.month, 1);
      expect(datetime.day, 1);
      expect(datetime.hour, 0);
      expect(datetime.minute, 0);
      expect(datetime.second, 0);
    });

    test('Year constructor', () {
      final year = Year(current.year);
      expect(year, isA<Year>());
      expect(year.year, current.year);
    });

    test('Year toString', () {
      final string = DateFormat("yyyy").format(now);
      expect(current.toString(), string);
    });

    test('Year operator ==', () {
      expect(current == now, isTrue);
      expect(current == current, isTrue);
      final followingYear = DateTime(now.year+1);
      final previousYear = DateTime(now.year-1);
      expect(current == previousYear, isFalse);
      expect(current == followingYear, isFalse);
      final followingMonth = DateTime(now.year, now.month+1);
      final previousMonth = DateTime(now.year, now.month-1);
      expect(current == DateTime(now.year, 0), isFalse);
      expect(current == DateTime(now.year, 1), isTrue);
      expect(current == DateTime(now.year, 12), isTrue);
      expect(current == DateTime(now.year, 13), isFalse);
      expect(current == previousMonth, now.month>1);
      expect(current == followingMonth, now.month<12);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      expect(current == now.yearStart.yesterday, isFalse);
      expect(current == now.yearStart, isTrue);
      expect(current == now.yearLast, isTrue);
      expect(current == now.yearLast.tomorrow, isFalse);
      expect(current == previousDay, !isFirst(now));
      expect(current == followingDay, !isLast(now));
    });

    test('Year operator <', () {
      final previousYear = DateTime(now.year-1);
      final followingYear = DateTime(now.year+1);
      expect(current < previousYear, isFalse);
      expect(current < followingYear, isTrue);
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current < DateTime(now.year, 0), isFalse);
      expect(current < DateTime(now.year, 1), isFalse);
      expect(current < DateTime(now.year, 12), isFalse);
      expect(current < DateTime(now.year, 13), isTrue);
      expect(current < previousMonth, isFalse);
      expect(current < followingMonth, now.month == 12);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current < now.yearStart.yesterday, isFalse);
      expect(current < now.yearStart, isFalse);
      expect(current < now.yearLast, isFalse);
      expect(current < now.yearLast.tomorrow, isTrue);
      expect(current < previousDay, isFalse);
      expect(current < followingDay, isLast(now));
    });

    test('Year operator <=', () {
      final previousYear = DateTime(now.year-1);
      final followingYear = DateTime(now.year+1);
      expect(current <= previousYear, isFalse);
      expect(current <= followingYear, isTrue);
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current <= DateTime(now.year, 0), isFalse);
      expect(current <= DateTime(now.year, 1), isTrue);
      expect(current <= DateTime(now.year, 12), isTrue);
      expect(current <= DateTime(now.year, 13), isTrue);
      expect(current <= previousMonth, !(now.month == 1));
      expect(current <= followingMonth, isTrue);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current <= now.yearStart.yesterday, isFalse);
      expect(current <= now.yearStart, isTrue);
      expect(current <= now.yearLast, isTrue);
      expect(current <= now.yearLast.tomorrow, isTrue);
      expect(current <= previousDay, !isFirst(now));
      expect(current <= followingDay, isTrue);
    });

    test('Year operator >', () {
      final previousYear = DateTime(now.year-1);
      final followingYear = DateTime(now.year+1);
      expect(current > previousYear, isTrue);
      expect(current > followingYear, isFalse);
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current > DateTime(now.year, 0), isTrue);
      expect(current > DateTime(now.year, 1), isFalse);
      expect(current > DateTime(now.year, 12), isFalse);
      expect(current > DateTime(now.year, 13), isFalse);
      expect(current > previousMonth, now.month == 1);
      expect(current > followingMonth, isFalse);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current > now.yearStart.yesterday, isTrue);
      expect(current > now.yearStart, isFalse);
      expect(current > now.yearLast, isFalse);
      expect(current > now.yearLast.tomorrow, isFalse);
      expect(current > previousDay, isFirst(now));
      expect(current > followingDay, isFalse);
    });

    test('Year operator >=', () {
      final previousYear = DateTime(now.year-1);
      final followingYear = DateTime(now.year+1);
      expect(current >= previousYear, isTrue);
      expect(current >= followingYear, isFalse);
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current >= DateTime(now.year, 0), isTrue);
      expect(current >= DateTime(now.year, 1), isTrue);
      expect(current >= DateTime(now.year, 12), isTrue);
      expect(current >= DateTime(now.year, 13), isFalse);
      expect(current >= previousMonth, isTrue);
      expect(current >= followingMonth, !(now.month == 12));
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current >= now.yearStart.yesterday, isTrue);
      expect(current >= now.yearStart, isTrue);
      expect(current >= now.yearLast, isTrue);
      expect(current >= now.yearLast.tomorrow, isFalse);
      expect(current >= previousDay, isTrue);
      expect(current >= followingDay, !isLast(now));
    });

    test('Year operator +', () {
      final previousYear = DateTime(now.year-1);
      final followingYear = DateTime(now.year+1);
      expect(current + -1, previousYear);
      expect(current + 1, followingYear);
    });

    test('Year operator -', () {
      final previousYear = DateTime(now.year-1);
      final followingYear = DateTime(now.year+1);
      expect(current - 1, previousYear);
      expect(current - -1, followingYear);
    });

    test('Year operator %', () {
      final previousYear = DateTime(now.year-1);
      final followingYear = DateTime(now.year+1);
      expect(current % previousYear, 1);
      expect(current % followingYear, -1);
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current % previousMonth, (now.month == 1) ? 1 : 0);
      expect(current % followingMonth, (now.month == 12) ? -1 : 0);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current % previousDay, isFirst(now) ? 1 : 0);
      expect(current % followingDay, isLast(now) ? -1 : 0);
    });

    test('yearStart', () {
      final first = current.yearStart;
      expect(first.year, current.year);
      expect(first.month, 1);
      expect(first.day, 1);
      expect(first.hour, 0);
      expect(first.minute, 0);
      expect(first.second, 0);
    });

    test('yearLast', () {
      final last = current.yearLast;
      expect(last.year, current.year);
      expect(last.month, 12);
      expect(last.day, 31);
      expect(last.hour, 0);
      expect(last.minute, 0);
      expect(last.second, 0);
    });

    test('yearEnd', () {
      final end = current.yearEnd;
      expect(end.year, current.year+1);
      expect(end.month, 1);
      expect(end.day, 1);
      expect(end.hour, 0);
      expect(end.minute, 0);
      expect(end.second, 0);
    });

    test('days', () {
      expect(Year(1600).days, 366);
      expect(Year(1700).days, 365);
      expect(Year(1800).days, 365);
      expect(Year(1900).days, 365);
      expect(Year(2000).days, 366);
      expect(Year(2020).days, 366);
      expect(Year(2021).days, 365);
      expect(Year(2022).days, 365);
      expect(Year(2023).days, 365);
      expect(Year(2024).days, 366);
      expect(Year(2025).days, 365);
      expect(Year(2026).days, 365);
      expect(Year(2027).days, 365);
      expect(Year(2028).days, 366);
      expect(Year(2029).days, 365);
      expect(Year(2030).days, 365);
      expect(Year(2031).days, 365);
      expect(Year(2032).days, 366);
      expect(Year(2100).days, 365);
    });
  });
}