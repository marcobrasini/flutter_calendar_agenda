import 'package:flutter/foundation.dart';
import 'package:calendar/src/utils/datetime.dart';


enum PatternType {
  daily,
  weekly,
  monthly,
  yearly,
}


class Pattern with Diagnosticable {

  Pattern({
    required this.since,
    required this.type,
    this.step = 1,
    this.count,
    this.until,
    this.exceptions = const {},
    this.recurrences = const [],
  });

  final PatternType type;
  final DateTime since;
  final int step;
  final int? count;
  final DateTime? until;
  final Set<DateTime> exceptions;
  List<Date> recurrences;

  PatternIterator get iterator {
    switch(type) {
      case PatternType.daily:
        return PatternDaily(this);
      case PatternType.weekly:
        return PatternWeekly(this);
      case PatternType.monthly:
        return PatternMonthly(this);
      case PatternType.yearly:
        return PatternYearly(this);
    }
  }

  @override
  int get hashCode => Object.hash(since, type, step, count, until);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is Pattern) {
      return other.since == since
          && other.type == type
          && other.step == step
          && other.count == count
          && other.until == until;
    }
    return false;
  }
}


class PatternIterator implements Iterator<DateTime> {
  PatternIterator(this.pattern) : current = pattern.since, index = 0;

  final Pattern pattern;
  DateTime current;
  int index;
  int _i = 0;

  DateTime initDateTime() => pattern.since.round();

  @override
  bool moveNext() {
    final next = nextDateTime();
    if (pattern.count != null && index >= pattern.count!) return false;
    if (pattern.until != null && !next.isBefore(pattern.until!)) return false;
    current = next;
    if (pattern.exceptions.isNotEmpty
        && pattern.exceptions.contains(current)) {
      return moveNext();
    }
    index = index + 1;
    return true;
  }

  DateTime nextDateTime() {
    throw UnimplementedError();
  }
}


class PatternDaily extends PatternIterator {
  PatternDaily(super.pattern) {
    pattern.recurrences = [];
  }

  @override
  DateTime nextDateTime() {
    if (index == 0) return initDateTime();
    final time = current.time;
    final date = current.date + pattern.step;
    return date & time;
  }
}


class PatternWeekly extends PatternIterator {
  PatternWeekly(super.pattern);

  bool isRecurrence(DateTime date) => pattern.recurrences.any(
          (value) => (date.weekday == value.weekday)
  );

  @override
  DateTime nextDateTime() {
    final time = current.time;
    Week week = current.toWeek;
    Date date, item;
    if (index == 0) {
      if (pattern.recurrences.isEmpty) return initDateTime();
      if (isRecurrence(pattern.since)) return initDateTime();
    }
    final recurrences = pattern.recurrences.isNotEmpty
        ? pattern.recurrences
        : [pattern.since.date];
    while (true) {
      for (var i = 0; i < recurrences.length - _i; i++) {
        item = recurrences[_i + i];
        date = week.date + (item.weekday - 1);
        if (date % current > 0) {
          _i = (_i + i) % recurrences.length;
          return date & time;
        }
      }
      _i = 0;
      week += pattern.step;
    }
  }
}


class PatternMonthly extends PatternIterator {
  PatternMonthly(super.pattern);

  bool isRecurrence(DateTime date) => pattern.recurrences.any(
          (value) => (date.day == value.day)
  );

  @override
  DateTime nextDateTime() {
    final time = current.time;
    Month month = current.toMonth;
    Date date, item;
    if (index == 0) {
      if (pattern.recurrences.isEmpty) return initDateTime();
      if (isRecurrence(pattern.since)) return initDateTime();
    }
    final recurrences = pattern.recurrences.isNotEmpty
        ? pattern.recurrences
        : [pattern.since.date];
    while (true) {
      for (var i = 0; i < recurrences.length - _i; i++) {
        item = recurrences[_i + i];
        date = Date(month.year, month.month, item.day);
        if (date % current > 0) {
          if (date.day == item.day) {
            _i = (_i + i) % recurrences.length;
            return date & time;
          }
          index += 1;
        }
      }
      _i = 0;
      month += pattern.step;
    }
  }
}


class PatternYearly extends PatternIterator {
  PatternYearly(super.pattern);
  
  bool isRecurrence(DateTime date) => pattern.recurrences.any(
          (value) => (date.month == value.month) && (date.day == value.day)
  );

  @override
  DateTime nextDateTime() {
    final time = current.time;
    Year year = current.toYear;
    Date date, item;
    if (index == 0) {
      if (pattern.recurrences.isEmpty) return initDateTime();
      if (isRecurrence(pattern.since)) return initDateTime();
    }
    final recurrences = pattern.recurrences.isNotEmpty
        ? pattern.recurrences
        : [pattern.since.date];
    while (true) {
      for (var i = 0; i < recurrences.length - _i; i++) {
        item = recurrences[_i + i];
        date = Date(year.year, item.month, item.day);
        if (date % current > 0) {
          if (date.month == item.month && date.day == item.day) {
            _i = (_i + i) % recurrences.length;
            return date & time;
          }
          index += 1;
        }
      }
      _i = 0;
      year += pattern.step;
    }
  }
}

