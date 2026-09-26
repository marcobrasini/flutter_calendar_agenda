import 'package:calendar/calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:meta/meta.dart';


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


class Pattern extends Equatable {
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
  final int? count;
  final DateTime? until;
  final Set<DateTime> exceptions;
  final List<Date> recurrences;

  Pattern({
    required this.type,
    this.step = 1,
    this.count,
    this.until,
    Set<DateTime>? exceptions,
    List<Date>? recurrences,
  }) : exceptions = Set.unmodifiable(exceptions ?? const <DateTime>{}),
        recurrences = List.unmodifiable(recurrences ?? const <Date>[]);

  factory Pattern.make({required Map<String, dynamic> data}) => Pattern(
    type: data["type"] as PatternType,
    step: data["step"] ?? 1,
    count: data["count"],
    until: data["until"],
    exceptions: data["exceptions"],
    recurrences: data["recurrences"],
  );

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
      until: (properties["until"] != null) ? DateTime.parse(properties["until"]!).toTZ() : null,
      exceptions: {
        for (String date in (properties["exceptions"]?.split(',') ?? []))
          DateTime.parse(date).toTZ()
      }
    );
  }

  String toICSString() {
    final rrule = <String>["FREQ=${_typeToIcs[type]}"];
    if (step != 1) rrule.add("INTERVAL=$step");
    if (count != null) rrule.add("COUNT=$count");
    if (until != null) rrule.add("UNTIL=${until!.fromTZ().toISOString()}");
    String string = "RRULE:${rrule.join(";")}";
    if (exceptions.isNotEmpty) {
      final exdate = exceptions.map((date) => date.fromTZ().toISOString()).toList();
      string = "$string\nEXDATE:${exdate.join(",")}";
    }
    return string;
  }

  Map<String, dynamic> get() => {
    "type": type,
    "step": step,
    "count": count,
    "until": until,
    "exceptions": exceptions,
    "recurrences": recurrences,
  };

  @useResult
  Pattern set(Map<String, dynamic> data) =>
      Pattern.make(data: {...get(), ...data..remove('type')});

  @useResult
  Pattern setStep(int step) => set({
    'step': step,
  });

  @useResult
  Pattern setCount(int count) => set({
    'count': count,
  });

  @useResult
  Pattern setUntil(DateTime until) => set({
    'until': until,
  });

  @useResult
  Pattern addException(DateTime datetime) => set({
    'exceptions': {...exceptions, datetime},
  });

  @useResult
  Pattern delException(DateTime datetime) => set({
    'exceptions': exceptions.where((d) => d != datetime).toSet(),
  });

  @useResult
  Pattern addRecurrence(Date date) => set({
    'recurrences': [...recurrences, date],
  });

  @useResult
  Pattern delRecurrence(Date date) => set({
    'recurrences': recurrences.where((d) => d != date).toList(),
  });

  @useResult
  Pattern shift(Duration duration) => set({
    'until':      until?.add(duration),
    'exceptions': exceptions.map((e) => e.add(duration)).toSet(),
  });

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

  bool get limited => count != null || until != null;

  @override
  List<Object?> get props =>
      [type, step, count, until, exceptions, recurrences];

  @override
  bool get stringify => true;
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
    if (pattern.until != null && next.isAfter(pattern.until!)) return false;
    current = next;
    _first = false;
    print(current);
    print(pattern.exceptions);
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
  PatternDaily(super.pattern, super.since);

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

