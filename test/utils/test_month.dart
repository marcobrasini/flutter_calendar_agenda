import 'package:intl/intl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final now = DateTime.now();
  final current = Month.now();

  group('Month', () {

    test('Month now', () {
      expect(current, isA<Month>());
      expect(current.year, now.year);
      expect(current.month, now.month);
    });

    test('Month from DateTime constructor', () {
      final month = now.toMonth;
      expect(month, isA<Month>());
      expect(month.year, now.year);
      expect(month.month, now.month);
    });

    test('Month constructor', () {
      final month = Month(current.year, current.month);
      expect(month, isA<Month>());
      expect(month.year, current.year);
      expect(month.month, current.month);
    });

    test('Month toString', () {
      final string = DateFormat("yyyy MMMM").format(now);
      expect(current.toString(), string);
    });

    test('Month operator ==', () {
      final following = Month(current.year, current.month+1);
      final previous = Month(current.year, current.month-1);
      expect(current == now, true);
      expect(current == current, true);
      expect(current == previous, false);
      expect(current == following, false);
    });

    test('Date operator <', () {
      final following = Month(current.year, current.month+1);
      final previous = Month(current.year, current.month-1);
      expect(current < following, true);
      expect(current < previous, false);
    });

    test('Date operator >', () {
      final following = Month(current.year, current.month+1);
      final previous = Month(current.year, current.month-1);
      expect(current > following, false);
      expect(current > previous, true);
    });

    test('Date operator +', () {
      final following = Month(current.year, current.month+1);
      final previous = Month(current.year, current.month-1);
      expect(current + 1 == following, true);
      expect(current + -1 == previous, true);
      final followingYear = Month(current.year, current.month+12);
      final previousYear = Month(current.year, current.month-12);
      expect(followingYear.year, current.year+1);
      expect(previousYear.year, current.year-1);
      expect(current + 12 == followingYear, true);
      expect(current + -12 == previousYear, true);
    });

    test('Date operator -', () {
      final following = Month(current.year, current.month+1);
      final previous = Month(current.year, current.month-1);
      expect(current - 1 == previous, true);
      expect(current - -1 == following, true);
      final followingYear = Month(current.year, current.month+12);
      final previousYear = Month(current.year, current.month-12);
      expect(followingYear.year, current.year+1);
      expect(previousYear.year, current.year-1);
      expect(current - 12 == previousYear, true);
      expect(current - -12 == followingYear, true);
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