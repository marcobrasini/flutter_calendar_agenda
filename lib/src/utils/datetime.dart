import 'package:intl/intl.dart';


class Time extends DateTime {
  Time._(super.year, super.month, super.day, super.hour, super.minute);

  factory Time(int hour, int minute) => Time._(1, 1, 1, hour, minute);
  factory Time.fromHour(int hours) => Time(hours, 0);
  factory Time.fromMinutes(int minutes) => Time(minutes ~/ 60, minutes % 60);

  static final TimeBeg beg = TimeBeg();
  static final TimeEnd end = TimeEnd();
  static Time now() => DateTime.now().time;

  @override
  String toString() {
    final String h = hour.toString().padLeft(2, '0');
    final String m = minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  factory Time.fromString(String timeString) {
    List<String> time = timeString.split(":");
    final int hour = int.parse(time[0]);
    final int minute = int.parse(time[1]);
    return Time(hour, minute);
  }

  factory Time.fromISOFormat(String dateString) => DateTime.parse(dateString).time;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    if (other is TimeBeg || other is TimeEnd) return false;
    return hour == other.hour && minute == other.minute;
  }

  bool operator <(DateTime dateTime) {
    if (dateTime is TimeBeg) return false;
    if (dateTime is TimeEnd) return true;
    return isBefore(dateTime.time);
  }

  bool operator >(DateTime dateTime) {
    if (dateTime is TimeBeg) return true;
    if (dateTime is TimeEnd) return false;
    return isAfter(dateTime.time);
  }

  bool operator <=(DateTime dateTime) => this < dateTime || this == dateTime;

  bool operator >=(DateTime dateTime) => this > dateTime || this == dateTime;

  Time operator +(int minutes) => Time(hour, minute + minutes);

  Time operator -(int minutes) => Time(hour, minute - minutes);

  int operator %(DateTime dateTime) => toUtc().difference(
      ((dateTime is TimeEnd) ? Time.end : dateTime.time).toUtc()
  ).inMinutes;

  Time round(int step) {
    final totalMinutes = hour * 60 + minute;
    final roundMinutes = ((totalMinutes + step ~/ 2) ~/ step) * step;
    final finalMinutes = roundMinutes % (24 * 60);
    return Time(finalMinutes ~/ 60, finalMinutes % 60);
  }
}

class TimeEnd extends Time {
  TimeEnd._() : super._(1, 1, 2, 0, 0);

  static final TimeEnd _instance = TimeEnd._();
  factory TimeEnd() => _instance;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => Object.hash(super.hashCode, 'TimeEnd');
}

class TimeBeg extends Time {
  TimeBeg._() : super._(1, 1, 1, 0, 0);

  static final TimeBeg _instance = TimeBeg._();
  factory TimeBeg() => _instance;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => Object.hash(super.hashCode, 'TimeBeg');
}

class Date extends DateTime {
  Date(super.year, super.month, super.day);

  static Date now() => DateTime.now().date;

  @override
  DateTime toUtc() => DateTime.utc(year, month, day);

  @override
  String toString() {
    String y = year.toString().padLeft(4, '0');
    String m = month.toString().padLeft(2, '0');
    String d = day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  factory Date.fromString(String dateString) {
    List<String> list = dateString.split("-");
    final int year = int.parse(list[0]);
    final int month = int.parse(list[1]);
    final int day = int.parse(list[2]);
    return Date(year, month, day);
  }

  factory Date.fromISOFormat(String dateString) => DateTime.parse(dateString).date;

  String format(String fmt) => DateFormat(fmt).format(this);

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    return year == other.year && month == other.month && day == other.day;
  }

  bool operator <(DateTime dateTime) => isBefore(dateTime.date);

  bool operator >(DateTime dateTime) => isAfter(dateTime.date);

  bool operator <=(DateTime dateTime) => this < dateTime || this == dateTime;

  bool operator >=(DateTime dateTime) => this > dateTime || this == dateTime;

  Date operator +(int days) => Date(year, month, day + days);

  Date operator -(int days) => Date(year, month, day - days);

  int operator %(DateTime dateTime) => toUtc().difference(
      dateTime.date.toUtc()
  ).inDays;

  DateTime get end => DateTime(year, month, day + 1);
}


class Week extends DateTime {
  static final weekDays = Week(2024, 0);

  final int week;
  final int weekYear;

  Week._(super.year, super.month, super.day, this.week, this.weekYear);

  factory Week(int year, [int week = 0]) {
    final weekYear = year + (week ~/ 53);
    final date = DateTime(weekYear).weekStart.date + (week % 53) * 7;
    return Week._(date.year, date.month, date.day, week % 53, weekYear);
  }

  Date get mon => Date(year, month, day + 0);
  Date get tue => Date(year, month, day + 1);
  Date get wed => Date(year, month, day + 2);
  Date get thu => Date(year, month, day + 3);
  Date get fri => Date(year, month, day + 4);
  Date get sat => Date(year, month, day + 5);
  Date get sun => Date(year, month, day + 6);

  static Week now() => DateTime.now().toWeek;

  @override
  String toString() => "$mon,$sun";

  String format(String fmt) => DateFormat(fmt).format(this);

  @override
  int get hashCode => Object.hash(year, month, day, week, weekYear);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    other = other.toWeek;
    return year == other.year && month == other.month && day == other.day;
  }

  bool operator <(DateTime dateTime) => sun < dateTime.date;

  bool operator >(DateTime dateTime) => mon > dateTime.date;

  bool operator <=(DateTime dateTime) => mon <= dateTime.date;

  bool operator >=(DateTime dateTime) => sun >= dateTime.date;

  Week operator +(int weeks) => (date + (7 * weeks)).toWeek;

  Week operator -(int weeks) => (date - (7 * weeks)).toWeek;

  int operator %(DateTime dateTime) => (date % dateTime) ~/ 7;
  
  DateTime newMonth(int month) => this;
  DateTime endMonth(int month) => this;
  
  DateTime newYear() => DateTime(year).weekStart;
  DateTime endYear() => DateTime(year+1, 1, 0).weekEnd.add(Duration(days:7));

  Date get first => mon;
  Date get last => sun;
}


class Month extends DateTime {
  Month(super.year, super.month);

  static Month now() {
    final now = DateTime.now();
    return Month(now.year, now.month);
  }

  @override
  String toString([String fmt = "yyyy-MM"]) => format(fmt);

  String format(String fmt) => DateFormat(fmt).format(this);

  factory Month.fromString(String dateString) {
    List<String> list = dateString.split("-");
    final int year = int.parse(list[0]);
    final int month = int.parse(list[1]);
    return Month(year, month);
  }

  @override
  int get hashCode => Object.hash(year, month);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    return year == other.year && month == other.month;
  }

  bool operator <(DateTime dateTime) => isBefore(dateTime.toMonth);

  bool operator >(DateTime dateTime) => isAfter(dateTime.toMonth);

  bool operator <=(DateTime dateTime) => this == dateTime || this < dateTime;

  bool operator >=(DateTime dateTime) => this == dateTime || this > dateTime;

  Month operator +(int months) => Month(year, month + months);

  Month operator -(int months) => Month(year, month - months);

  int operator %(DateTime dateTime) => (year - dateTime.year)*12 + (month - dateTime.month);

  Date get first => DateTime(year, month, 1).date;
  Date get last => DateTime(year, month + 1, 0).date;
  int get days => last.day;
}


class Year extends DateTime {
  Year(super.year);

  static Year now() {
    final now = DateTime.now();
    return Year(now.year);
  }

  @override
  String toString([String fmt = "yyyy"]) => format(fmt);

  String format(String fmt) => DateFormat(fmt).format(this);

  @override
  int get hashCode => year;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    return year == other.year;
  }

  bool operator <(DateTime dateTime) => isBefore(dateTime.toYear);

  bool operator >(DateTime dateTime) => isAfter(dateTime.toYear);

  bool operator <=(DateTime dateTime) => this == dateTime || this < dateTime;

  bool operator >=(DateTime dateTime) => this == dateTime || this > dateTime;

  Year operator +(int years) => Year(year + years);

  Year operator -(int years) => Year(year - years);

  int operator %(DateTime dateTime) => year - dateTime.year;

  int get days => isLeapYear ? 366 : 365;
  Date get first => DateTime(year, 1, 1).date;
  Date get last => DateTime(year + 1, 1, 0).date;
}


extension DateAndTime on DateTime {

  Time get time => Time(hour, minute);
  Date get date => Date(year, month, day);
  Week get toWeek {
    final days = weekStart.date % DateTime(year).weekStart.date;
    return Week(year, days ~/ 7);
  }
  Month get toMonth => Month(year, month);
  Year get toYear => Year(year);

  String toISOString() => ""
      "${year.toString().padLeft(4, '0')}"
      "${month.toString().padLeft(2, '0')}"
      "${day.toString().padLeft(2, '0')}T"
      "${hour.toString().padLeft(2, '0')}"
      "${minute.toString().padLeft(2, '0')}"
      "${second.toString().padLeft(2, '0')}"
      "${isUtc ? 'Z' : ''}";

  String format(String fmt) => DateFormat(fmt).format(this);
  DateTime round() => date & time;

  Date get tomorrow => date + 1;
  Date get yesterday => date - 1;
  bool get isLeapYear => (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  int get dayNumber => date % Year(year);

  DateTime get weekStart => DateTime(year, month, day - (weekday - 1));
  // DateTime get weekLast => DateTime(year, month, day + (7 - weekday));
  DateTime get weekEnd => DateTime(year, month, day + (8 - weekday));
  DateTime get monthStart => DateTime(year, month);
  // DateTime get monthLast => DateTime(year, month + 1, 0);
  DateTime get monthEnd => DateTime(year, month + 1);
  DateTime get yearStart => DateTime(year);
  // DateTime get yearLast => DateTime(year + 1, 1, 0);
  DateTime get yearEnd => DateTime(year + 1, 1);

  DateTime operator &(DateTime datetime) => DateTime(
      year, month, day,
      datetime.hour, datetime.minute, datetime.second
  );
}
