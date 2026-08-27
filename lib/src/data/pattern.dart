import 'package:flutter/foundation.dart';
import 'package:calendar/src/utils/datetime.dart';


enum PatternType {
  daily,
  weekly,
  monthly,
  yearly,
}

String? patternRRULE(String source, String property) {
  final index = source.indexOf(property);
  if (index == -1) return null;
  final start = index + ("$property=").length;
  final stop = source.indexOf(";", start);
  return stop == -1
      ? source.substring(start)
      : source.substring(start, stop);
}

String? patternEXDATE(String source) {
  final index = source.indexOf("EXDATE:");
  if (index == -1) return null;
  final start = index + ("EXDATE:").length;
  final stop = source.indexOf(";", start);
  return stop == -1
      ? source.substring(start)
      : source.substring(start, stop);
}


class Pattern with Diagnosticable {
  static const _icsToType = {
    "DAILY": PatternType.daily,
    "WEEKLY": PatternType.weekly,
    "MONTHLY": PatternType.monthly,
    "YEARLY": PatternType.yearly,
  };
  static const _typeToIcs = {
    PatternType.daily: "DAILY",
    PatternType.weekly: "WEEKLY",
    PatternType.monthly: "MONTHLY",
    PatternType.yearly: "YEARLY",
  };

  final PatternType type;
  final int step;
  int? count;
  DateTime? until;
  Set<DateTime> exceptions;
  List<Date> recurrences;

  Pattern({
    required this.type,
    this.step = 1,
    this.count,
    this.until,
    Set<DateTime>? exceptions,
    List<Date>? recurrences,
  }) : exceptions = exceptions ?? <DateTime>{},
        recurrences = recurrences ?? <Date>[];

  factory Pattern.fromICSString(String string) {
    final rrule = string.replaceAll("\n", ";");
    final properties = {
      "type": patternRRULE(rrule, "FREQ"),
      "step": patternRRULE(rrule, "INTERVAL"),
      "count": patternRRULE(rrule, "COUNT"),
      "until": patternRRULE(rrule, "UNTIL"),
      "exceptions": patternEXDATE(rrule),
    };
    return Pattern(
      type: _icsToType[properties["type"]!]!,
      step: (properties["step"] != null) ? int.parse(properties["step"]!) : 1,
      count: (properties["count"] != null) ? int.parse(properties["count"]!) : null,
      until: (properties["until"] != null) ? DateTime.parse(properties["until"]!) : null,
      exceptions: {
        for (String date in (properties["exceptions"]?.split(',') ?? []))
          DateTime.parse(date)
      }
    );
  }

  String toICSString() {
    final rrule = <String>["FREQ=${_typeToIcs[type]}"];
    if (step != 1) rrule.add("INTERVAL=$step");
    if (count != null) rrule.add("COUNT=$count");
    if (until != null) rrule.add("UNTIL=${until!.toISOString()}");
    String string = "RRULE:${rrule.join(";")}";
    if (exceptions.isNotEmpty) {
      final exdate = exceptions.map((date) => date.toISOString()).toList();
      string = "$string\nEXDATE:${exdate.join(",")}";
    }
    return string;
  }

  PatternIterator iterator(DateTime datetime) {
    switch(type) {
      case PatternType.daily:
        return PatternDaily(this, datetime);
      case PatternType.weekly:
        return PatternWeekly(this, datetime);
      case PatternType.monthly:
        return PatternMonthly(this, datetime);
      case PatternType.yearly:
        return PatternYearly(this, datetime);
    }
  }

  @override
  int get hashCode => Object.hash(type, step, count, until);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is Pattern) {
      return other.type == type
          && other.step == step
          && other.count == count
          && other.until == until;
    }
    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PatternType>('type', type));
    properties.add(IntProperty('step', step));
    properties.add(IntProperty('count', count));
    properties.add(DiagnosticsProperty<DateTime>('until', until));
  }
}


class PatternIterator implements Iterator<DateTime> {
  PatternIterator(this.pattern, this.since) : current = since, index = 0;

  final Pattern pattern;
  final DateTime since;
  @override DateTime current;
  int index;
  bool _first = true;
  int _i = 0;

  DateTime initDateTime() => since.round();

  @override
  bool moveNext() {
    final next = nextDateTime();
    if (pattern.count != null && index >= pattern.count!) return false;
    if (pattern.until != null && !next.isBefore(pattern.until!)) return false;
    current = next;
    _first = false;
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
  PatternDaily(super.pattern, super.since) {
    pattern.recurrences = [];
  }

  @override
  DateTime nextDateTime() {
    if (_first) return initDateTime();
    final time = current.time;
    final date = current.date + pattern.step;
    return date & time;
  }
}


class PatternWeekly extends PatternIterator {
  PatternWeekly(super.pattern, super.since);

  bool isRecurrence(DateTime date) => pattern.recurrences.any(
          (value) => (date.weekday == value.weekday)
  );

  @override
  DateTime nextDateTime() {
    final time = current.time;
    Week week = current.toWeek;
    Date date, item;
    if (_first) {
      if (pattern.recurrences.isEmpty) return initDateTime();
      if (isRecurrence(since)) return initDateTime();
    }
    final recurrences = pattern.recurrences.isNotEmpty
        ? pattern.recurrences
        : [since.date];
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
  PatternMonthly(super.pattern, super.since);

  bool isRecurrence(DateTime date) => pattern.recurrences.any(
          (value) => (date.day == value.day)
  );

  @override
  DateTime nextDateTime() {
    final time = current.time;
    Month month = current.toMonth;
    Date date, item;
    if (_first) {
      if (pattern.recurrences.isEmpty) return initDateTime();
      if (isRecurrence(since)) return initDateTime();
    }
    final recurrences = pattern.recurrences.isNotEmpty
        ? pattern.recurrences
        : [since.date];
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
  PatternYearly(super.pattern, super.since);
  
  bool isRecurrence(DateTime date) => pattern.recurrences.any(
          (value) => (date.month == value.month) && (date.day == value.day)
  );

  @override
  DateTime nextDateTime() {
    final time = current.time;
    Year year = current.toYear;
    Date date, item;
    if (_first) {
      if (pattern.recurrences.isEmpty) return initDateTime();
      if (isRecurrence(since)) return initDateTime();
    }
    final recurrences = pattern.recurrences.isNotEmpty
        ? pattern.recurrences
        : [since.date];
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

