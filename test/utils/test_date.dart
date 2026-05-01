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

    test('Date from DateTime', () {
      final date = now.date;
      expect(date, isA<Date>());
      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
    });

    test('Date as DateTime', () {
      final datetime = today as DateTime;
      expect(datetime, isA<DateTime>());
      expect(datetime.year, today.year);
      expect(datetime.month, today.month);
      expect(datetime.day, today.day);
      expect(datetime.hour, 0);
      expect(datetime.minute, 0);
      expect(datetime.second, 0);
    });

    test('Date constructor', () {
      final date = Date(year, month, day);
      expect(date, isA<DateTime>());
      expect(date.year, year);
      expect(date.month, month);
      expect(date.day, day);
    });

    test('Date toString', () {
      final string = DateFormat("yyyy-MM-dd").format(now);
      expect(today.toString(), string);
    });

    test('Date fromString', () {
      final string = now.toString();
      final date = Date.fromString(string.split(' ')[0]);
      expect(date.year, year);
      expect(date.month, month);
      expect(date.day, day);
    });

    test('Date operator ==', () {
      final yesterday = DateTime(now.year, now.month, now.day-1);
      final tomorrow = DateTime(now.year, now.month, now.day+1);
      expect(today == yesterday, isFalse);
      expect(today == today, isTrue);
      expect(today == now, isTrue);
      expect(today == tomorrow, isFalse);
    });

    test('Date operator <', () {
      final yesterday = DateTime(now.year, now.month, now.day-1);
      final tomorrow = DateTime(now.year, now.month, now.day+1);
      expect(today < yesterday, isFalse);
      expect(today < today, isFalse);
      expect(today < now, isFalse);
      expect(today < tomorrow, isTrue);
    });

    test('Date operator <=', () {
      final yesterday = DateTime(now.year, now.month, now.day-1);
      final tomorrow = DateTime(now.year, now.month, now.day+1);
      expect(today <= yesterday, isFalse);
      expect(today <= today, isTrue);
      expect(today <= now, isTrue);
      expect(today <= tomorrow, isTrue);
    });

    test('Date operator >', () {
      final yesterday = DateTime(now.year, now.month, now.day-1);
      final tomorrow = DateTime(now.year, now.month, now.day+1);
      expect(today > yesterday, isTrue);
      expect(today > today, isFalse);
      expect(today > now, isFalse);
      expect(today > tomorrow, isFalse);
    });

    test('Date operator >=', () {
      final yesterday = DateTime(now.year, now.month, now.day-1);
      final tomorrow = DateTime(now.year, now.month, now.day+1);
      expect(today >= yesterday, isTrue);
      expect(today >= today, isTrue);
      expect(today >= now, isTrue);
      expect(today >= tomorrow, isFalse);
    });

    test('Date operator +', () {
      final yesterday = DateTime(now.year, now.month, now.day-1);
      final tomorrow = DateTime(now.year, now.month, now.day+1);
      expect(today + -1, yesterday);
      expect(today + 1, tomorrow);
      final lastMonthDays = (now.toMonth-1).days;
      final thisMonthDays = (now.toMonth+0).days;
      final previousMonth = DateTime(now.year, now.month, now.day-lastMonthDays);
      final followingMonth = DateTime(now.year, now.month, now.day+thisMonthDays);
      expect(today + -lastMonthDays, previousMonth);
      expect(today + thisMonthDays, followingMonth);
      expect(previousMonth.day, now.day);
      expect(followingMonth.day, now.day);
      expect(previousMonth.month, now.month - 1);
      expect(followingMonth.month, now.month + 1);
      final yearDays = now.toYear.days;
      final previousYear = DateTime(now.year, now.month, now.day-yearDays);
      final followingYear = DateTime(now.year, now.month, now.day+yearDays);
      expect(today + -yearDays, previousYear);
      expect(today + yearDays, followingYear);
      expect(previousYear.day, now.day);
      expect(followingYear.day, now.day);
      expect(previousYear.month, now.month);
      expect(followingYear.month, now.month);
      expect(previousYear.year, now.year - 1);
      expect(followingYear.year, now.year + 1);
    });

    test('Date operator -', () {
      final yesterday = DateTime(now.year, now.month, now.day-1);
      final tomorrow = DateTime(now.year, now.month, now.day+1);
      expect(today - 1, yesterday);
      expect(today - -1, tomorrow);
      final lastMonthDays = (now.toMonth-1).days;
      final thisMonthDays = (now.toMonth+0).days;
      final previousMonth = DateTime(now.year, now.month, now.day-lastMonthDays);
      final followingMonth = DateTime(now.year, now.month, now.day+thisMonthDays);
      expect(today - lastMonthDays, previousMonth);
      expect(today - -thisMonthDays, followingMonth);
      expect(previousMonth.day, now.day);
      expect(followingMonth.day, now.day);
      expect(previousMonth.month, now.month - 1);
      expect(followingMonth.month, now.month + 1);
      final lastYearDays = (now.toYear-1).days;
      final thisYearDays = (now.toYear+0).days;
      final previousYear = DateTime(now.year, now.month, now.day-lastYearDays);
      final followingYear = DateTime(now.year, now.month, now.day+thisYearDays);
      expect(today - lastYearDays, previousYear);
      expect(today - -thisYearDays, followingYear);
      expect(previousYear.day, now.day);
      expect(followingYear.day, now.day);
      expect(previousYear.month, now.month);
      expect(followingYear.month, now.month);
      expect(previousYear.year, now.year - 1);
      expect(followingYear.year, now.year + 1);
    });

    test('Date operator %', () {
      final yesterday = DateTime(now.year, now.month, now.day-1);
      final tomorrow = DateTime(now.year, now.month, now.day+1);
      expect(today % yesterday == 1, true);
      expect(today % tomorrow == -1, true);
    });
  });
}