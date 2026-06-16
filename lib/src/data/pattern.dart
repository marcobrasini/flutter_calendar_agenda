import 'package:rrule/rrule.dart';
import 'package:flutter/foundation.dart';
import 'package:calendar/src/utils/datetime.dart';


enum PatternType {
  daily,
  weekly,
  monthly,
  yearly,
}


class Pattern with Diagnosticable {
  static const _ICSToType = {
    "DAILY": PatternType.daily,
    "WEEKLY": PatternType.weekly,
    "MONTHLY": PatternType.monthly,
    "YEARLY": PatternType.yearly,
  };
  static const _TypeToICS = {
    PatternType.daily: "DAILY",
    PatternType.weekly: "WEEKLY",
    PatternType.monthly: "MONTHLY",
    PatternType.yearly: "YEARLY",
  };

  final PatternType type;
  final DateTime since;
  final int step;
  final int? count;
  final DateTime? until;
  final Set<DateTime> exceptions;
  List<Date> recurrences;

  Pattern({
    required this.since,
    required this.type,
    this.step = 1,
    this.count,
    this.until,
    this.exceptions = const {},
    this.recurrences = const [],
  });

  factory Pattern.fromICSString(DateTime since, String rule) {
    final rrule = RecurrenceRule.fromString(rule);
    final type = Pattern._ICSToType[rrule.frequency.toString()]!;
    final recurrences = <Date>[];
    switch (type) {
      case PatternType.daily:
        break;
      case PatternType.weekly:
        for (var day in rrule.byWeekDays) {
          recurrences.add(Date(2024, 1, day.day));
        }
        break;
      case PatternType.monthly:
        for (var day in rrule.byMonthDays) {
          recurrences.add(Date(2024, 1, day));
        }
        break;
      case PatternType.yearly:
        for (var month in rrule.byMonths) {
          if (rrule.byMonthDays.isEmpty) {
            recurrences.add(Date(2024, month, 1));
          } else {
            for (var day in rrule.byMonthDays) {
              recurrences.add(Date(2024, month, day));
            }
          }
        }
        for (var day in rrule.byYearDays) {
          recurrences.add(Date(2024, 1, day));
        }
        break;
    }
    return Pattern(
      since: since,
      type: type,
      step: rrule.interval ?? 1,
      count: rrule.count,
      until: rrule.until,
      recurrences: recurrences,
    );
  }

  String toICSString() {
    final strings = <String>["FREQ:${_TypeToICS[type]}"];
    if (step != 1) strings.add("INTERVAL=$step");
    if (count != null) strings.add("COUNT=$count");
    if (until != null) strings.add("UNTIL=${until!.toISOCompact()}");
    if (exceptions.isNotEmpty) {
      final dates = exceptions.map((e) => e.toISOCompact()).join(",");
      strings.add("EXDATE=$dates");
    }
    return "RRULE:${strings.join(";")};";
  }

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
  @override DateTime current;
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

