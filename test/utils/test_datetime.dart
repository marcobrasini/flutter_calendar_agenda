import 'package:test/test.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final now = DateTime.now();

  group('DateTime', () {

    test('toMonth', () {
      final month = now.toMonth;
      expect(month, isA<Month>());
      expect(month.year, now.year);
      expect(month.month, now.month);
    });

    test('toWeek', () {
      final date = now.weekBeg;
      final week = now.toWeek;
      expect(week, isA<Week>());
      expect(week.year, date.year);
      expect(week.month, date.month);
      expect(week.day, date.day);
    });

    test('toDate', () {
      final date = now.toDate;
      expect(date, isA<Date>());
      expect(date.year, now.year);
      expect(date.month, now.month);
      expect(date.day, now.day);
    });

    test('toTime', () {
      final time = now.toTime;
      expect(time, isA<Time>());
      expect(time.hour, now.hour);
      expect(time.minute, now.minute);
    });

    test('toISOCompact', () {
      final isoString = now.toString().split('.')[0].split(" ");
      expect(now.toISOCompact(), ""
          "${isoString[0].replaceAll('-', '')}T"
          "${isoString[1].replaceAll(':', '')}Z");
    });

    test('dayBeg', () {
      final dayBeg = now.dayBeg;
      expect(dayBeg, isA<DateTime>());
      expect(dayBeg.year, now.year);
      expect(dayBeg.month, now.month);
      expect(dayBeg.day, now.day);
      expect(dayBeg.hour, 0);
      expect(dayBeg.minute, 0);
    });

    test('dayEnd', () {
      final dayEnd = now.dayEnd;
      expect(dayEnd, isA<DateTime>());
      expect(dayEnd.year, now.year);
      expect(dayEnd.month, now.month);
      expect(dayEnd.day, now.day + 1);
      expect(dayEnd.hour, 0);
      expect(dayEnd.minute, 0);
    });

    test('weekBeg', () {
      final weekBeg = now.weekBeg;
      expect(weekBeg, isA<DateTime>());
      expect(weekBeg.weekday, DateTime.monday);
      expect(weekBeg.hour, 0);
      expect(weekBeg.minute, 0);
    });

    test('weekEnd', () {
      final weekEnd = now.weekEnd;
      expect(weekEnd, isA<DateTime>());
      expect(weekEnd.weekday, DateTime.monday);
      expect(weekEnd.hour, 0);
      expect(weekEnd.minute, 0);
    });

    test('monthBeg', () {
      final monthBeg = now.monthBeg;
      expect(monthBeg, isA<DateTime>());
      expect(monthBeg.year, now.year);
      expect(monthBeg.month, now.month);
      expect(monthBeg.day, 1);
      expect(monthBeg.hour, 0);
      expect(monthBeg.minute, 0);
    });

    test('monthEnd', () {
      final monthEnd = now.monthEnd;
      expect(monthEnd, isA<DateTime>());
      expect(monthEnd.year, now.year);
      expect(monthEnd.month, now.month + 1);
      expect(monthEnd.day, 1);
      expect(monthEnd.hour, 0);
      expect(monthEnd.minute, 0);
    });

  });
}
