import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final now = DateTime.now();
  final current = Week.now();

  bool isFirst(DateTime datetime) => datetime.date == datetime.weekStart;
  bool isLast(DateTime datetime) => datetime.date == datetime.weekLast;

  void isWeek(Week week) {
    expect(current, isA<Week>());
    expect(week.mon.weekday, DateTime.monday);
    expect(week.tue.weekday, DateTime.tuesday);
    expect(week.wed.weekday, DateTime.wednesday);
    expect(week.thu.weekday, DateTime.thursday);
    expect(week.fri.weekday, DateTime.friday);
    expect(week.sat.weekday, DateTime.saturday);
    expect(week.sun.weekday, DateTime.sunday);
  }

  void expectWeek(Week week, DateTime datetime) {
    final days = datetime.weekStart.date % DateTime(datetime.year);
    final weeks = (days < 0) ? 0 : days ~/ 7 + 1;
    expect(week.week, weeks);
  }

  void expectExact(Week week, int year) {
    expect(week.year, year);
    expect(week.mon.year, year);
    expect(week.sun.year, year);
  }

  void expectFirst(Week week, int year) {
    expect(week.year, year - 1);
    expect(week.mon.year, year - 1);
    expect(week.sun.year, year);
  }

  void expectLast(Week week, int year) {
    expect(week.year, year);
    expect(week.mon.year, year);
    expect(week.sun.year, year + 1);
  }

  void expectYear(Week week, int year) {
    if (week >= Date(year, 12, 25)) {
      (DateTime(year, 12, 31).weekday == DateTime.sunday)
          ? expectExact(week, year)
          : expectLast(week, year);
      expect(week.week, 52);
    } else if (week <= Date(year, 1, 7)) {
      (DateTime(year, 1, 1).weekday == DateTime.monday)
          ? expectExact(week, year)
          : expectFirst(week, year);
      expect(week.week, 0);
    } else {
      expectExact(week, year);
    }
  }

  void expectDay(Week week, DateTime datetime) {
    expect(week.mon == datetime, datetime.weekday == DateTime.monday);
    expect(week.tue == datetime, datetime.weekday == DateTime.tuesday);
    expect(week.wed == datetime, datetime.weekday == DateTime.wednesday);
    expect(week.thu == datetime, datetime.weekday == DateTime.thursday);
    expect(week.fri == datetime, datetime.weekday == DateTime.friday);
    expect(week.sat == datetime, datetime.weekday == DateTime.saturday);
    expect(week.sun == datetime, datetime.weekday == DateTime.sunday);
  }

  group('Week', () {

    test('first Week exact', () {
      // leap year
      int year = 2024;
      Week week = Week(year, 0);
      isWeek(week);
      if (week <= Date(year, 1, 7)) {
        expect(DateTime(year, 1, 1).weekday, DateTime.monday);
        expect(DateTime(year, 1, 7).weekday, DateTime.sunday);
        expectExact(week, year);
        expect(week.week, 0);
      }
      // normal year
      year = 2018;
      week = Week(year, 0);
      isWeek(week);
      if (week <= Date(year, 1, 7)) {
        expect(DateTime(year, 1, 1).weekday, DateTime.monday);
        expect(DateTime(year, 1, 7).weekday, DateTime.sunday);
        expectExact(week, year);
        expect(week.week, 0);
      }
    });

    test('last Week exact', () {
      // leap year
      int year = 2023;
      Week week = Week(year, 52);
      isWeek(week);
      if (week >= Date(year, 12, 25)) {
        expect(DateTime(year, 12, 25).weekday, DateTime.monday);
        expect(DateTime(year, 12, 31).weekday, DateTime.sunday);
        expectExact(week, year);
        expect(week.week, 52);
      }
      // normal year
      year = 2017;
      week = Week(year, 52);
      isWeek(week);
      if (week >= Date(year, 12, 25)) {
        expect(DateTime(year, 12, 25).weekday, DateTime.monday);
        expect(DateTime(year, 12, 31).weekday, DateTime.sunday);
        expectExact(week, year);
        expect(week.week, 52);
      }
    });

    test('first Week', () {
      final year = now.year;
      final week = Week(year, 0);
      expect(week, isA<Week>());
      if (week <= Date(year, 1, 7)) {
        (DateTime(year, 1, 1).weekday == DateTime.monday)
          ? expectExact(week, year)
          : expectFirst(week, year);
        expectWeek(week, DateTime(year));
        expect(week.week, 0);
      }
      isWeek(week);
    });

    test('last Week', () {
      final year = now.year;
      final week = Week(year, 52);
      expect(week, isA<Week>());
      if (week >= Date(year, 12, 25)) {
        (DateTime(year, 12, 31).weekday == DateTime.sunday)
          ? expectExact(week, year)
          : expectLast(week, year);
        expectWeek(week, DateTime(year, 12, 31));
        expect(week.week, 52);
      }
      isWeek(week);
    });

    test('now', () {
      isWeek(current);
      expectYear(current, now.year);
      expectWeek(current, now);
      expectDay(current, now);
    });

    test('Week from DateTime', () {
      final week = now.toWeek;
      isWeek(week);
      expectYear(week, now.year);
      expectWeek(week, now);
      expectDay(week, now);
    });

    test('Week as DateTime constructor', () {
      final datetime = current as DateTime;
      expect(datetime, isA<DateTime>());
      expect(datetime.year, current.year);
      expect(datetime.month, current.month);
      expect(datetime.day, current.day);
      expect(datetime.hour, 0);
      expect(datetime.minute, 0);
      expect(datetime.second, 0);
    });

    test('Week constructor', () {
      final week = Week(current.year, current.week);
      expect(week, isA<Week>());
      expect(week.year, current.year);
      expect(week.week, current.week);
    });

    test('Week toString', () {
      final string = "${current.mon},${current.sun}";
      expect(current.toString(), string);
    });

    test('Week operator ==', () {
      expect(current == now, isTrue);
      expect(current == current, isTrue);
      final previousWeek = DateTime(now.year, now.month, now.day-7);
      final followingWeek = DateTime(now.year, now.month, now.day+7);
      expect(current == previousWeek, isFalse);
      expect(current == followingWeek, isFalse);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current == now.weekStart.yesterday, isFalse);
      expect(current == now.weekStart, isTrue);
      expect(current == now.weekLast, isTrue);
      expect(current == now.weekLast.tomorrow, isFalse);
      expect(current == previousDay, !isFirst(now));
      expect(current == followingDay, !isLast(now));
    });

    test('Week operator <', () {
      final previousWeek = DateTime(now.year, now.month, now.day-7);
      final followingWeek = DateTime(now.year, now.month, now.day+7);
      expect(current < previousWeek, isFalse);
      expect(current < followingWeek, isTrue);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current < now.weekStart.yesterday, isFalse);
      expect(current < now.weekStart, isFalse);
      expect(current < now.weekLast, isFalse);
      expect(current < now.weekLast.tomorrow, isTrue);
      expect(current < previousDay, isFalse);
      expect(current < followingDay, isLast(now));
    });

    test('Week operator <=', () {
      final previousWeek = DateTime(now.year, now.month, now.day-7);
      final followingWeek = DateTime(now.year, now.month, now.day+7);
      expect(current <= previousWeek, isFalse);
      expect(current <= followingWeek, isTrue);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current <= now.weekStart.yesterday, isFalse);
      expect(current <= now.weekStart, isTrue);
      expect(current <= now.weekLast, isTrue);
      expect(current <= now.weekLast.tomorrow, isTrue);
      expect(current <= previousDay, !isFirst(now));
      expect(current <= followingDay, isTrue);
    });

    test('Week operator >', () {
      final previousWeek = DateTime(now.year, now.month, now.day-7);
      final followingWeek = DateTime(now.year, now.month, now.day+7);
      expect(current > previousWeek, isTrue);
      expect(current > followingWeek, isFalse);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current > now.weekStart.yesterday, isTrue);
      expect(current > now.weekStart, isFalse);
      expect(current > now.weekLast, isFalse);
      expect(current > now.weekLast.tomorrow, isFalse);
      expect(current > previousDay, isFirst(now));
      expect(current > followingDay, isFalse);
    });

    test('Week operator >=', () {
      final previousWeek = DateTime(now.year, now.month, now.day-7);
      final followingWeek = DateTime(now.year, now.month, now.day+7);
      expect(current >= previousWeek, isTrue);
      expect(current >= followingWeek, isFalse);
      final previousDay = DateTime(now.year, now.month, now.day-1);
      final followingDay = DateTime(now.year, now.month, now.day+1);
      expect(current >= now.weekStart.yesterday, isTrue);
      expect(current >= now.weekStart, isTrue);
      expect(current >= now.weekLast, isTrue);
      expect(current >= now.weekLast.tomorrow, isFalse);
      expect(current >= previousDay, isTrue);
      expect(current >= followingDay, !isLast(now));
    });

    test('Week operator +', () {
      final previousWeek = DateTime(now.year, now.month, now.day-7);
      final followingWeek = DateTime(now.year, now.month, now.day+7);
      expect(current + -1, previousWeek.toWeek);
      expect(current + 1, followingWeek.toWeek);
      final previousYear = DateTime(now.year-1, now.month, now.day);
      final followingYear = DateTime(now.year+1, now.month, now.day);
      expect(current + -52, previousYear.toWeek);
      expect(current + 52, followingYear.toWeek);
    });

    test('Week operator -', () {
      final previousWeek = DateTime(now.year, now.month, now.day-7);
      final followingWeek = DateTime(now.year, now.month, now.day+7);
      expect(current - 1, previousWeek.toWeek);
      expect(current - -1, followingWeek.toWeek);
      final previousYear = DateTime(now.year-1, now.month, now.day);
      final followingYear = DateTime(now.year+1, now.month, now.day);
      expect(current - 52, previousYear.toWeek);
      expect(current - -52, followingYear.toWeek);
    });
  });
}