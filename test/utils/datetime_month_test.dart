import 'package:intl/intl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final now = DateTime.now();
  final current = Month.now();

  DateTime first(DateTime datetime) => DateTime(datetime.year, datetime.month, 1);
  DateTime last(DateTime datetime) => DateTime(datetime.year, datetime.month+1, 0);

  bool isFirst(DateTime datetime) => datetime.date == first(datetime);
  bool isLast(DateTime datetime) => datetime.date == last(datetime);

  group('Month', () {

    test('Month now', () {
      expect(current, isA<Month>());
      expect(current.year, now.year);
      expect(current.month, now.month);
    });

    test('Month from DateTime', () {
      final month = now.toMonth;
      expect(month, isA<Month>());
      expect(month.year, now.year);
      expect(month.month, now.month);
    });

    test('Month as DateTime', () {
      final datetime = current as DateTime;
      expect(datetime, isA<DateTime>());
      expect(datetime.year, now.year);
      expect(datetime.month, now.month);
      expect(datetime.day, 1);
      expect(datetime.hour, 0);
      expect(datetime.minute, 0);
      expect(datetime.second, 0);
    });

    test('Month constructor', () {
      final month = Month(current.year, current.month);
      expect(month, isA<Month>());
      expect(month.year, current.year);
      expect(month.month, current.month);
    });

    test('Month format', () {
      final fmt = "MMMM yyyy";
      final string = DateFormat(fmt).format(now);
      expect(current.format(fmt), string);
    });

    test('Month toString', () {
      final string = DateFormat("yyyy-MM").format(now);
      expect(current.toString(), string);
    });

    test('Month fromString', () {
      final string = now.toString();
      final month = Month.fromString(string.split(' ')[0]);
      expect(month.year, now.year);
      expect(month.month, now.month);
    });

    test('Month operator ==', () {
      expect(current == now, isTrue);
      expect(current == current, isTrue);
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current == previousMonth, isFalse);
      expect(current == followingMonth, isFalse);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current == first(now).yesterday, isFalse);
      expect(current == first(now), isTrue);
      expect(current == last(now), isTrue);
      expect(current == last(now).tomorrow, isFalse);
      expect(current == previousDay, !isFirst(now));
      expect(current == followingDay, !isLast(now));
    });

    test('Month operator <', () {
      final previousMonth = DateTime(current.year, current.month-1);
      final followingMonth = DateTime(current.year, current.month+1);
      expect(current < previousMonth, isFalse);
      expect(current < followingMonth, isTrue);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current < first(now).yesterday, isFalse);
      expect(current < first(now), isFalse);
      expect(current < last(now), isFalse);
      expect(current < last(now).tomorrow, isTrue);
      expect(current < previousDay, isFalse);
      expect(current < followingDay, isLast(now));
    });

    test('Month operator <=', () {
      final previousMonth = DateTime(current.year, current.month-1);
      final followingMonth = DateTime(current.year, current.month+1);
      expect(current <= previousMonth, isFalse);
      expect(current <= followingMonth, isTrue);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current <= first(now).yesterday, isFalse);
      expect(current <= first(now), isTrue);
      expect(current <= last(now), isTrue);
      expect(current <= last(now).tomorrow, isTrue);
      expect(current <= previousDay, !isFirst(now));
      expect(current <= followingDay, isTrue);
    });

    test('Month operator >', () {
      final previousMonth = DateTime(current.year, current.month-1);
      final followingMonth = DateTime(current.year, current.month+1);
      expect(current > previousMonth, isTrue);
      expect(current > followingMonth, isFalse);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current > first(now).yesterday, isTrue);
      expect(current > first(now), isFalse);
      expect(current > last(now), isFalse);
      expect(current > last(now).tomorrow, isFalse);
      expect(current > previousDay, isFirst(now));
      expect(current > followingDay, isFalse);
    });

    test('Month operator >=', () {
      final previousMonth = DateTime(current.year, current.month-1);
      final followingMonth = DateTime(current.year, current.month+1);
      expect(current >= previousMonth, isTrue);
      expect(current >= followingMonth, isFalse);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current >= first(now).yesterday, isTrue);
      expect(current >= first(now), isTrue);
      expect(current >= last(now), isTrue);
      expect(current >= last(now).tomorrow, isFalse);
      expect(current >= previousDay, isTrue);
      expect(current >= followingDay, !isLast(now));
    });

    test('Month operator +', () {
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current + -1, previousMonth);
      expect(current + 1, followingMonth);
      final previousYear = DateTime(now.year, now.month-12);
      final followingYear = DateTime(now.year, now.month+12);
      expect(current + -12, previousYear);
      expect(current + 12, followingYear);
      expect(previousYear.year, now.year-1);
      expect(followingYear.year, now.year+1);
    });

    test('Month operator -', () {
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current - 1, previousMonth);
      expect(current - -1, followingMonth);
      final previousYear = DateTime(now.year, now.month-12);
      final followingYear = DateTime(now.year, now.month+12);
      expect(current - 12, previousYear);
      expect(current - -12, followingYear);
      expect(previousYear.year, now.year-1);
      expect(followingYear.year, now.year+1);
    });

    test('Month operator %', () {
      final previousYear = DateTime(now.year-1, now.month);
      final followingYear = DateTime(now.year+1, now.month);
      expect(current % previousYear, 12);
      expect(current % followingYear, -12);
      final previousMonth = DateTime(now.year, now.month-1);
      final followingMonth = DateTime(now.year, now.month+1);
      expect(current % previousMonth, 1);
      expect(current % followingMonth, -1);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current % previousDay, isFirst(now) ? 1 : 0);
      expect(current % followingDay, isLast(now) ? -1 : 0);
    });

    test('monthStart', () {
      final start = current.monthStart;
      expect(start.year, current.year);
      expect(start.month, current.month);
      expect(start.day, 1);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });

    test('monthLast', () {
      final last = current.monthLast;
      expect(last.year, current.year);
      expect(last.month, current.month);
      if ([1, 3, 5, 7, 8, 10, 12].contains(current.month)) {
        expect(last.day, 31);
      } else if ([4, 6, 9, 11].contains(current.month)) {
        expect(last.day, 30);
      } else if (current.month == 2) {
        expect(last.day, current.isLeapYear ? 29 : 28);
      }
      expect(last.hour, 0);
      expect(last.minute, 0);
      expect(last.second, 0);
    });

    test('monthEnd', () {
      final end = current.monthEnd;
      expect(end.year, current.year);
      expect(end.month, current.month+1);
      expect(end.day, 1);
      expect(end.hour, 0);
      expect(end.minute, 0);
      expect(end.second, 0);
    });

    test('days', () {
      expect(Month(2025, 1).days, 31);
      expect(Month(2025, 2).days, 28);
      expect(Month(2025, 3).days, 31);
      expect(Month(2025, 4).days, 30);
      expect(Month(2025, 5).days, 31);
      expect(Month(2025, 6).days, 30);
      expect(Month(2025, 7).days, 31);
      expect(Month(2025, 8).days, 31);
      expect(Month(2025, 9).days, 30);
      expect(Month(2025, 10).days, 31);
      expect(Month(2025, 11).days, 30);
      expect(Month(2025, 12).days, 31);
      // special February days
      expect(Month(2000, 2).days, 29);
      expect(Month(2100, 2).days, 28);
      expect(Month(1900, 2).days, 28);
    });
  });
}