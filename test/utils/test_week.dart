import 'package:test/test.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final now = DateTime.now();
  final current = Week.now();

  void expectDays(Week week) {
    expect(current.mon.weekday, DateTime.monday);
    expect(current.tue.weekday, DateTime.tuesday);
    expect(current.wed.weekday, DateTime.wednesday);
    expect(current.thu.weekday, DateTime.thursday);
    expect(current.fri.weekday, DateTime.friday);
    expect(current.sat.weekday, DateTime.saturday);
    expect(current.sun.weekday, DateTime.sunday);
  }

  void expectWeek(Week week, DateTime datetime) {
    final days = datetime.weekBeg.toDate % DateTime(datetime.year);
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
      if (DateTime(year, 12, 31).weekday == DateTime.sunday) {
        expectExact(week, year);
      } else {
        expectLast(week, year);
      }
      expect(week.week, 52);
    } else if (week <= Date(year, 1, 7)) {
      if (DateTime(year, 1, 1).weekday == DateTime.monday) {
        expectExact(week, year);
      } else {
        expectFirst(week, year);
      }
      expect(week.week, 0);
    } else {
      expectExact(week, year);
    }
  }

  void expectDay(Week week, DateTime datetime) {
    expect(week.toDate + 0 == datetime, datetime.weekday == DateTime.monday);
    expect(week.toDate + 1 == datetime, datetime.weekday == DateTime.tuesday);
    expect(week.toDate + 2 == datetime, datetime.weekday == DateTime.wednesday);
    // expect(week.toDate + 3 == datetime, datetime.weekday == DateTime.thursday);
    // expect(week.toDate + 4 == datetime, datetime.weekday == DateTime.friday);
    // expect(week.toDate + 5 == datetime, datetime.weekday == DateTime.saturday);
    // expect(week.toDate + 6 == datetime, datetime.weekday == DateTime.sunday);
  }

  group('Week', () {

    test('first Week exact', () {
      // leap year
      int year = 2024;
      Week week = Week(year, 0);
      expect(week, isA<Week>());
      if (week <= Date(year, 1, 1)) {
        expect(DateTime(year, 1, 1).weekday, DateTime.sunday);
        expectExact(week, year);
        expect(week.week, 0);
      }
      expectDays(week);
      // normal year
      year = 2018;
      week = Week(year, 0);
      expect(week, isA<Week>());
      if (week <= Date(year, 1, 1)) {
        expect(DateTime(year, 1, 1).weekday, DateTime.sunday);
        expectExact(week, year);
        expect(week.week, 0);
      }
      expectDays(week);
    });

    test('last Week exact', () {
      // leap year
      int year = 2023;
      Week week = Week(year, 52);
      expect(week, isA<Week>());
      if (week >= Date(year, 12, 25)) {
        expect(DateTime(year, 12, 31).weekday, DateTime.sunday);
        expectExact(week, year);
        expect(week.week, 52);
      }
      expectDays(week);
      // normal year
      year = 2017;
      week = Week(year, 52);
      expect(week, isA<Week>());
      if (week >= Date(year, 12, 25)) {
        expect(DateTime(year, 12, 31).weekday, DateTime.sunday);
        expectExact(week, year);
        expect(week.week, 52);
      }
      expectDays(week);
    });

    test('first Week', () {
      final year = now.year;
      final week = Week(year, 0);
      expect(week, isA<Week>());
      if (week <= Date(year, 1, 7)) {
        if (DateTime(year, 1, 1).weekday == DateTime.monday) {
          expectExact(week, year);
        } else {
          expectFirst(week, year);
        }
        expectWeek(week, DateTime(year));
        expect(week.week, 0);
      }
      expectDays(week);
    });

    test('last Week', () {
      final year = now.year;
      final week = Week(year, 52);
      expect(week, isA<Week>());
      if (week >= Date(year, 12, 25)) {
        if (DateTime(year, 12, 31).weekday == DateTime.sunday) {
          expectExact(week, year);
        } else {
          expectLast(week, year);
        }
        expectWeek(week, DateTime(year, 12, 31));
        expect(week.week, 52);
      }
      expectDays(week);
    });

    test('now', () {
      expect(current, isA<Week>());
      expectYear(current, now.year);
      expectWeek(current, now);
      expectDays(current);
      expectDay(current, now);
    });

    test('Week constructor', () {
      final week = Week(current.year, current.week);
      expect(week, isA<Week>());
      expect(week.year, current.year);
      expect(week.week, current.week);
    });

    test('Week from DateTime constructor', () {
      final week = now.toWeek;
      expect(week, isA<Week>());
      expectYear(week, now.year);
      expectWeek(week, now);
      expectDays(week);
      expectDay(week, now);
    });

    test('Week as DateTime constructor', () {
      final datetime = current as DateTime;
      expect(datetime, isA<DateTime>());
      expect(datetime.year, current.mon.year);
      expect(datetime.month, current.mon.month);
      expect(datetime.day, current.mon.day);
    });

    test('Date toString', () {
      final string = current.toString();
      expect(string, isA<String>());
      expect(string, "${current.mon},${current.sun}");
    });

    test('Date operator ==', () {
      final following = now.add(Duration(days: 7));
      final previous = now.add(Duration(days: -7));
      expect(current == now, now.weekday == DateTime.monday);
      expect(current == now.weekBeg, true);
      expect(current == now.weekEnd, false);
      expect(current == following, false);
      expect(current == previous, false);
    });

    test('Date operator <', () {
      final following = now.add(Duration(days: 7));
      final previous = now.add(Duration(days: -7));
      expect(current < now, false);
      expect(current < now.weekBeg, false);
      expect(current < now.weekEnd, true);
      expect(current < following, true);
      expect(current < previous, false);
    });

    test('Date operator <=', () {
      final following = now.add(Duration(days: 7));
      final previous = now.add(Duration(days: -7));
      expect(current <= now, now.weekday == DateTime.sunday);
      expect(current <= now.weekBeg, false);
      expect(current <= now.weekEnd, true);
      expect(current <= following, true);
      expect(current <= previous, false);
    });

    test('Date operator >', () {
      final following = now.add(Duration(days: 7));
      final previous = now.add(Duration(days: -7));
      expect(current > now, false);
      expect(current > now.weekBeg, false);
      expect(current > now.weekEnd, false);
      expect(current > following, false);
      expect(current > previous, true);
    });

    test('Date operator >=', () {
      final following = now.add(Duration(days: 7));
      final previous = now.add(Duration(days: -7));
      expect(current >= now, now.weekday == DateTime.monday);
      expect(current >= now.weekBeg, true);
      expect(current >= now.weekEnd, false);
      expect(current >= following, false);
      expect(current >= previous, true);
    });

    test('Date operator +', () {
      final following = now.add(Duration(days: 7));
      final previous = now.add(Duration(days: -7));
      expect(current + 1 == following.toWeek, true);
      expect(current + -1 == previous.toWeek, true);
    });

    test('Date operator -', () {
      final following = now.add(Duration(days: 7));
      final previous = now.add(Duration(days: -7));
      expect(current - -1 == following.toWeek, true);
      expect(current - 1 == previous.toWeek, true);
    });
  });
}