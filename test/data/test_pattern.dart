import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/data/pattern.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {

  final since = DateTime.now();

  group('Pattern daily', () {
    final step = 3;
    final count = 5;
    final after = 20;
    final until = since.date + after;
    final length = after ~/ step + (after % step == 0 ? 0 : 1);
    final exceptions = {
      since.add(Duration(days: step)).round(),
      since.add(Duration(days: 6*step)).round(),
    };
    final allExceptions = {
      for (int i = 0 ; i < length; i++)
        ((since.date + (i * step)) & since.time).round(),
    };
    final exceptionLength = exceptions.where((d) => d.isBefore(until)).length;
    final rrule = "RRULE:FREQ=DAILY;INTERVAL=$step;COUNT=$count;"
        "UNTIL=${until.toISOString()};EXDATE=${exceptions.map(
            (e) => e.toISOString()).join(",")};";

    test('Pattern constructor default', () {
      final pattern = Pattern(
        type: PatternType.daily,
      );
      expect(pattern.type, PatternType.daily);
      expect(pattern.step, 1);
      expect(pattern.count, isNull);
      expect(pattern.until, isNull);
      expect(pattern.exceptions, isEmpty);
      expect(pattern.recurrences, isEmpty);
    });

    test('Pattern constructor', () {
      final pattern = Pattern(
        type: PatternType.daily,
        step: step,
        count: count,
        until: until,
        exceptions: exceptions,
      );
      expect(pattern.type, PatternType.daily);
      expect(pattern.step, step);
      expect(pattern.count, count);
      expect(pattern.until, until);
      expect(pattern.exceptions, exceptions);
      expect(pattern.recurrences, isEmpty);
    });

    test('Pattern constructor fromISOString', () {
      final pattern = Pattern.fromICSString(rrule);
      expect(pattern.type, PatternType.daily);
      expect(pattern.step, step);
      expect(pattern.count, count);
      expect(pattern.until, until);
      expect(pattern.exceptions, exceptions);
      expect(pattern.recurrences, isEmpty);
    });

    test('Pattern toISOString', () {
      print(until.isUtc);
      final pattern = Pattern(
        type: PatternType.daily,
        step: step,
        count: count,
        until: until,
        exceptions: exceptions,
      );
      expect(pattern.toICSString(), rrule);
    });

    test('Pattern iterator count', () {
      final pattern = Pattern(
        type: PatternType.daily,
        step: step,
        count: count,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(iterator, isA<PatternDaily>());
      expect(dates.length, count);
      for (var i = 0; i < dates.length; i++) {
        expect((dates[i].date % since) % step, 0);
        expect((dates[i].date % since), i*step);
        expect(dates[i], since.add(Duration(days: i*step)).round());
      }
    });

    test('Pattern iterator count with exceptions', () {
      final pattern = Pattern(
        type: PatternType.daily,
        step: step,
        count: count,
        exceptions: exceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(iterator, isA<PatternDaily>());
      expect(dates.length, count);
      for (var date in dates) {
        expect((date.date % since) % step, 0);
        expect(exceptions.contains(date), isFalse);
      }
    });

    test('Pattern iterator until', () {
      final pattern = Pattern(
        type: PatternType.daily,
        step: step,
        until: until,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(iterator, isA<PatternDaily>());
      expect(dates.length, length);
      for (var i = 0; i < dates.length; i++) {
        expect((dates[i].date % since) % step, 0);
        expect((dates[i].date % since), i*step);
        expect(dates[i].isBefore(until), isTrue);
      }
    });

    test('Pattern iterator until with exceptions', () {
      final pattern = Pattern(
        type: PatternType.daily,
        step: step,
        until: until,
        exceptions: exceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(iterator, isA<PatternDaily>());
      expect(dates.length, length - exceptionLength);
      for (var date in dates) {
        expect((date.date % since) % step, 0);
        expect(date.isBefore(until), isTrue);
        expect(exceptions.contains(date), isFalse);
      }
    });

    test('Pattern iterator all exceptions', () {
      final pattern = Pattern(
        type: PatternType.daily,
        step: step,
        until: until,
        exceptions: allExceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.isEmpty, true);
    });

  });

  group('Pattern weekly', () {
    final step = 2;
    final count = 5;
    final after = 20;
    final until = since.toWeek + after;
    final length = after ~/ (step) + (after % (step) == 0 ? 0 : 1);
    final exceptions = {
      since.add(Duration(days: 7)).round(),
      since.add(Duration(days: 28)).round(),
    };
    final allExceptions = {
      for (int i = 0 ; i <= length; i++)
        ((since.date + (i * step * 7)) & since.time).round(),
    };
    final exceptionLength = exceptions.where(
            (d) => d.isBefore(until) && ((d.toWeek % since) % step == 0)
    ).length;

    final weekdays = [3, 5];
    final recurrences = [
      since.toWeek.date + (weekdays[0] - 1),
      since.toWeek.date + (weekdays[1] - 1),
    ];
    final recurrenceExceptions = {
      (since.toWeek.date + (weekdays[1] - 1)) & since.time,
      (since.toWeek.date + (weekdays[0] - 1 + 14)) & since.time,
    };

    test('Pattern constructor default', () {
      final pattern = Pattern(
        type: PatternType.weekly,
      );
      expect(pattern.type, PatternType.weekly);
      expect(pattern.step, 1);
      expect(pattern.count, isNull);
      expect(pattern.until, isNull);
      expect(pattern.exceptions, isEmpty);
      expect(pattern.recurrences, isEmpty);
    });

    test('Pattern constructor', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        count: count,
        until: until,
        exceptions: exceptions,
        recurrences: recurrences,
      );
      expect(pattern.type, PatternType.weekly);
      expect(pattern.step, step);
      expect(pattern.count, count);
      expect(pattern.until, until);
      expect(pattern.exceptions, exceptions);
      expect(pattern.recurrences, recurrences);
    });

    test('Pattern iterator', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        count: count,
        until: until,
        exceptions: exceptions,
        recurrences: recurrences,
      );
      final iterator = pattern.iterator(since);
      expect(iterator, isA<PatternWeekly>());
      expect(pattern.recurrences, recurrences);
    });

    test('Pattern iterator count', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        count: count,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var i = 0; i < dates.length; i++) {
        expect((dates[i].date % since) % (step * 7), 0);
        expect((dates[i].date % since), i * step * 7);
        expect(dates[i], since.add(Duration(days: i * step * 7)).round());
      }
    });

    test('Pattern iterator count with exceptions', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        count: count,
        exceptions: exceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var date in dates) {
        expect((date.date % since) % (step * 7), 0);
        expect(exceptions.contains(date), isFalse);
      }
    });

    test('Pattern iterator count with recurrences', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        count: count,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var date in dates) {
        expect(weekdays.contains(date.weekday), isTrue);
      }
    });

    test('Pattern iterator count with recurrences and exceptions', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        count: count,
        exceptions: recurrenceExceptions,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var date in dates) {
        expect(recurrenceExceptions.contains(date), isFalse);
        expect(weekdays.contains(date.weekday), isTrue);
      }
    });

    test('Pattern iterator until', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        until: until,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, length);
      for (var i = 0; i < dates.length; i++) {
        expect((dates[i].date % since) % step, 0);
        expect((dates[i].date % since), i*step*7);
        expect(dates[i], (since.date + (i * step * 7)) & since.time);
      }
    });

    test('Pattern iterator until with exceptions', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        until: until,
        exceptions: exceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, length-exceptionLength);
      for (var date in dates) {
        expect(date.isBefore(until), isTrue);
        expect((date.date % since) % (step * 7), 0);
        expect(exceptions.contains(date), isFalse);
      }
    });

    test('Pattern iterator until with recurrences', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        until: until,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      for (var date in dates) {
        expect(date.isBefore(until), isTrue);
        expect(weekdays.contains(date.weekday), isTrue);
      }
    });

    test('Pattern iterator until with recurrences and exceptions', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        until: until,
        exceptions: recurrenceExceptions,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      for (var date in dates) {
        expect(date.isBefore(until), isTrue);
        expect(recurrenceExceptions.contains(date), isFalse);
        expect(weekdays.contains(date.weekday), isTrue);
      }
    });

    test('Pattern iterator until all exceptions', () {
      final pattern = Pattern(
        type: PatternType.weekly,
        step: step,
        until: until,
        exceptions: allExceptions,
      );
      print(until);
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      print(dates);
      expect(dates.isEmpty, isTrue);
    });
  });

  group('Pattern monthly', () {
    final step = 3;
    final count = 5;
    final after = 30;
    final until = since.toMonth + after;
    final length = after ~/ step + ((after % step) == 0 ? 0 : 1);

    final exceptions = {
      DateTime(since.year, since.month+step, since.day) & since.time,
      DateTime(since.year, since.month+18, since.day) & since.time,
    };
    final exceptionLength = exceptions.where(
            (d) => d.isBefore(until) && (d.toMonth % since) % step == 0
    ).length;

    final monthdays = [1, 14, 28];
    final recurrences = [
      DateTime(since.year).date + (monthdays[0]-1),
      DateTime(since.year).date + (monthdays[1]-1),
      DateTime(since.year).date + (monthdays[2]-1),
    ];
    final recurrenceExceptions = {
      DateTime(since.year, since.month, monthdays[2]) & since.time,
      DateTime(since.year, since.month+step, monthdays[1]) & since.time,
    };

    final critic = Date(since.year, 1, 31);
    final skips = List.generate(count, (i) {
      final month = since.month + (since.isBefore(critic) ? i : i + 1);
      return Month(since.year, month).days != 31;
    }).where((b) => b).length;

    test('Pattern constructor default', () {
      final pattern = Pattern(
        type: PatternType.monthly,
      );
      expect(pattern.type, PatternType.monthly);
      expect(pattern.step, 1);
      expect(pattern.count, isNull);
      expect(pattern.until, isNull);
      expect(pattern.exceptions, isEmpty);
      expect(pattern.recurrences, isEmpty);
    });

    test('Pattern constructor', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        count: count,
        until: until,
        exceptions: exceptions,
        recurrences: recurrences,
      );
      expect(pattern.type, PatternType.monthly);
      expect(pattern.step, step);
      expect(pattern.count, count);
      expect(pattern.until, until);
      expect(pattern.exceptions, exceptions);
      expect(pattern.recurrences, recurrences);
    });

    test('Pattern iterator', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        count: count,
        until: until,
        exceptions: exceptions,
        recurrences: recurrences,
      );
      final iterator = pattern.iterator(since);
      expect(iterator, isA<PatternMonthly>());
      expect(pattern.recurrences, recurrences);
    });

    test('Pattern iterator count', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        count: count,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var i = 0; i < dates.length; i++) {
        expect((dates[i].toMonth % since) % step, 0);
        expect((dates[i].toMonth % since), i * step);
        expect(dates[i], DateTime(since.year, since.month + i * step, since.day) & since.time);
      }
    });

    test('Pattern iterator count with exceptions', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        count: count,
        exceptions: exceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var date in dates) {
        expect((date.toMonth % since) % step, 0);
        expect(exceptions.contains(date), isFalse);
      }
    });

    test('Pattern iterator count with recurrences', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        count: count,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var date in dates) {
        expect((date.toMonth % since) % step, 0);
        expect(monthdays.contains(date.day), isTrue);
      }
    });

    test('Pattern iterator count with recurrences and exceptions', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        count: count,
        exceptions: recurrenceExceptions,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var date in dates) {
        expect((date.toMonth % since) % step, 0);
        expect(recurrenceExceptions.contains(date), isFalse);
        expect(monthdays.contains(date.day), isTrue);
      }
    });

    test('Pattern iterator until', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        until: until,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, length);
      for (var i = 0; i < dates.length; i++) {
        final date = DateTime(since.year, since.month + i * step, since.day);
        expect((dates[i].toMonth % since) % step, 0);
        expect((dates[i].toMonth % since), i * step);
        expect(dates[i], date & since.time);
      }
    });

    test('Pattern iterator until with exceptions', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        until: until,
        exceptions: exceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, length - exceptionLength);
      for (var date in dates) {
        expect((date.toMonth % since) % step, 0);
        expect(exceptions.contains(date), isFalse);
      }
    });

    test('Pattern iterator until with recurrences', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        until: until,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      for (var date in dates) {
        expect((date.toMonth % since) % step, 0);
        expect(monthdays.contains(date.day), isTrue);
      }
    });

    test('Pattern iterator until with recurrences and exceptions', () {
      final pattern = Pattern(
        type: PatternType.monthly,
        step: step,
        until: until,
        exceptions: recurrenceExceptions,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      for (var date in dates) {
        expect((date.toMonth % since) % step, 0);
        expect(recurrenceExceptions.contains(date), isFalse);
        expect(monthdays.contains(date.day), isTrue);
      }
    });

    test('Pattern iterator count with recurrences 31st', () {
      final pattern = Pattern(
          type: PatternType.monthly,
          step: 1,
          count: count,
          recurrences: [Date(since.year, 1, 31)]
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count-skips);
      for (var date in dates) {
        expect(date.day, 31);
      }
    });

    test('Pattern iterator count with recurrences 28th and 31st', () {
      final pattern = Pattern(
          type: PatternType.monthly,
          step: 1,
          count: 2*count,
          recurrences: [Date(since.year, 1, 28), Date(since.year, 1, 31)]
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, 2*count-skips);
      for (var date in dates) {
        expect(date.day == 28 || date.day == 31, isTrue);
      }
    });

  });

  group('Pattern yearly', () {
    final step = 2;
    final count = 14;
    final after = 15;
    final until = DateTime(since.year+after, since.month, since.day);
    final length = (until.toYear % since) ~/ step + (
        ((until.toYear % since) % step == 0 && (until.time < since.time)) ? 0 : 1
    );

    final exceptions = {
      DateTime(since.year+2, since.month, since.day) & since.time,
      DateTime(since.year+9, since.month, since.day) & since.time,
    };
    final exceptionLength = exceptions.where((d) {
      return d.isBefore(until) && d.year % step == 0;
    }).length;

    final recurrences = [
      Date(since.year, 1, 1),
      Date(since.year, 2, 28),
      Date(since.year, 12, 31),
    ];
    final recurrenceExceptions = {
      DateTime(since.year, recurrences[2].month, recurrences[2].day) & since.time,
      DateTime(since.year+step, recurrences[1].month, recurrences[1].day) & since.time,
    };
    final critic = Date(since.year, 2, 29);
    final skips = List.generate(count, (i) {
      final year = since.year + (since.isBefore(critic) ? i : i + 1);
      return !Year(year).isLeapYear;
    }).where((b) => b).length;

    test('Pattern constructor default', () {
      final pattern = Pattern(
        type: PatternType.yearly,
      );
      expect(pattern.type, PatternType.yearly);
      expect(pattern.step, 1);
      expect(pattern.count, isNull);
      expect(pattern.until, isNull);
      expect(pattern.exceptions, isEmpty);
      expect(pattern.recurrences, isEmpty);
    });

    test('Pattern constructor', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        count: count,
        until: until,
        exceptions: exceptions,
        recurrences: recurrences,
      );
      expect(pattern.type, PatternType.yearly);
      expect(pattern.step, step);
      expect(pattern.count, count);
      expect(pattern.until, until);
      expect(pattern.exceptions, exceptions);
      expect(pattern.recurrences, recurrences);
    });

    test('Pattern iterator', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        count: count,
        until: until,
        exceptions: exceptions,
        recurrences: recurrences,
      );
      final iterator = pattern.iterator(since);
      expect(iterator, isA<PatternYearly>());
      expect(pattern.recurrences, recurrences);
    });

    test('Pattern iterator count', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        count: count,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var i = 0; i < dates.length; i++) {
        final date = DateTime(since.year + i * step, since.month, since.day);
        expect((dates[i].toYear % since) % step, 0);
        expect((dates[i].toYear % since), i * step);
        expect(dates[i], date & since.time);
      }
    });

    test('Pattern iterator count with exceptions', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        count: count,
        exceptions: exceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      for (var date in dates) {
        expect((date.toYear % since) % step, 0);
        expect(exceptions.contains(date), isFalse);
      }
    });

    test('Pattern iterator count with recurrences', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        count: count,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var date in dates) {
        expect((date.toYear % since) % step, 0);
        expect(recurrences.any((value) =>
            date.month == value.month && date.day == value.day
        ), isTrue);
      }
    });

    test('Pattern iterator count with recurrences and exceptions', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        count: count,
        exceptions: recurrenceExceptions,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count);
      for (var date in dates) {
        expect((date.toYear % since) % step, 0);
        expect(recurrenceExceptions.contains(date), isFalse);
        expect(recurrences.any((value) =>
            date.month == value.month && date.day == value.day
        ), isTrue);
      }
    });

    test('Pattern iterator until', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        until: until,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, length);
      for (var i = 0; i < dates.length; i++) {
        final date = DateTime(since.year + i * step, since.month, since.day);
        expect((dates[i].toYear % since) % step, 0);
        expect((dates[i].toYear % since), i * step);
        expect(dates[i], date & since.time);
      }
    });

    test('Pattern iterator until with exceptions', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        until: until,
        exceptions: exceptions,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, length - exceptionLength);
      for (var date in dates) {
        expect((date.toYear % since) % step, 0);
        expect(exceptions.contains(date), isFalse);
      }
    });

    test('Pattern iterator until with recurrences', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        until: until,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      for (var date in dates) {
        expect((date.toYear % since) % step, 0);
        expect(recurrences.any((value) =>
            date.month == value.month && date.day == value.day
        ), isTrue);
      }
    });

    test('Pattern iterator until with recurrences and exceptions', () {
      final pattern = Pattern(
        type: PatternType.yearly,
        step: step,
        until: until,
        exceptions: recurrenceExceptions,
        recurrences: recurrences,
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      for (var date in dates) {
        expect((date.toYear % since) % step, 0);
        expect(recurrenceExceptions.contains(date), isFalse);
        expect(recurrences.any((value) =>
          date.month == value.month && date.day == value.day
        ), isTrue);
      }
    });

    test('Pattern iterator count with recurrences 2/29th', () {
      final pattern = Pattern(
          type: PatternType.yearly,
          step: 1,
          count: count,
          recurrences: [Date(2028, 2, 29)]
      );
      final List<DateTime> dates = [];
      final iterator = pattern.iterator(since);
      while (iterator.moveNext()) {
        dates.add(iterator.current);
      }
      expect(dates.length, count-skips);
      for (var date in dates) {
        expect(date.isLeapYear, isTrue);
        expect(date.month, 2);
        expect(date.day, 29);
      }
    });
  });
}