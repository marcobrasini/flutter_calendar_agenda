import 'package:intl/intl.dart';


class Time extends DateTime {
  Time(int hour, int minute) : super(1, 1, 1, hour, minute);

  static Time now() => DateTime.now().toTime;

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

  factory Time.fromISOFormat(String dateString) => DateTime.parse(dateString).toTime;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    return hour == other.hour && minute == other.minute;
  }

  bool operator <(DateTime dateTime) => isBefore(dateTime.toTime);

  bool operator >(DateTime dateTime) => isAfter(dateTime.toTime);

  bool operator <=(DateTime dateTime) => this < dateTime || this == dateTime;

  bool operator >=(DateTime dateTime) => this > dateTime || this == dateTime;

  Time operator +(int minutes) => Time(hour, minute + minutes);

  Time operator -(int minutes) => Time(hour, minute - minutes);

  int operator %(DateTime dateTime) => toUtc().difference(
      dateTime.toTime.toUtc()
  ).inMinutes;

  Time round(int step) {
    final totalMinutes = hour * 60 + minute;
    final roundMinutes = ((totalMinutes + step ~/ 2) ~/ step) * step;
    final finalMinutes = roundMinutes % (24 * 60);
    return Time(finalMinutes ~/ 60, finalMinutes % 60);
  }
}


class Date extends DateTime {
  Date(super.year, super.month, super.day);

  static Date now() => DateTime.now().toDate;

  @override
  String toString() {
    String y = year.toString().padLeft(4, '0');
    String m = month.toString().padLeft(2, '0');
    String d = day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  factory Date.fromString(String dateString) {
    List<String> date = dateString.split("-");
    final int year = int.parse(date[0]);
    final int month = int.parse(date[1]);
    final int day = int.parse(date[2]);
    return Date(year, month, day);
  }

  factory Date.fromISOFormat(String dateString) => DateTime.parse(dateString).toDate;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    return year == other.year && month == other.month && day == other.day;
  }

  bool operator <(DateTime dateTime) => isBefore(dateTime.toDate);

  bool operator >(DateTime dateTime) => isAfter(dateTime.toDate);

  bool operator <=(DateTime dateTime) => this < dateTime || this == dateTime;

  bool operator >=(DateTime dateTime) => this > dateTime || this == dateTime;

  Date operator +(int days) => Date(year, month, day + days);

  Date operator -(int days) => Date(year, month, day - days);

  int operator %(DateTime dateTime) => toUtc().difference(
      dateTime.toDate.toUtc()
  ).inDays;

  DateTime get end => DateTime(year, month, day + 1);
}


class Week extends DateTime {
  Week._(super.year, super.month, super.day, this.week);

  factory Week(int year, int week) {
    final date = DateTime(year).weekBeg.toDate + week*7;
    return Week._(date.year, date.month, date.day, week % 53);
  }

  final int week;
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

  @override
  int get hashCode => Object.hash(year, month, day, week);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    return year == other.year && month == other.month && day == other.day;
  }

  bool operator <(DateTime dateTime) => sun < dateTime.toDate;

  bool operator >(DateTime dateTime) => mon > dateTime.toDate;

  bool operator <=(DateTime dateTime) => sun <= dateTime.toDate;

  bool operator >=(DateTime dateTime) => mon >= dateTime.toDate;

  Week operator +(int weeks) => Week(year, week + weeks);

  Week operator -(int weeks) => Week(year, week - weeks);

  bool contains(DateTime datetime) => mon <= datetime && sun >= datetime;
}


class Month extends DateTime {
  Month(super.year, super.month);

  static Month now() {
    final now = DateTime.now();
    return Month(now.year, now.month);
  }

  @override
  String toString([String fmt = "yyyy MMMM"]) => format(fmt);

  @override
  int get hashCode => Object.hash(year, month);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DateTime) return false;
    return year == other.year && month == other.month;
  }

  bool operator <(DateTime dateTime) => isBefore(dateTime.toDate);

  bool operator >(DateTime dateTime) => isAfter(dateTime.toDate);

  Month operator +(int months) => Month(year, month + months);

  Month operator -(int months) => Month(year, month - months);

  int operator %(DateTime dateTime) => toUtc().difference(
      dateTime.toMonth.toUtc()
  ).inDays;

  int get days => DateTime(year, month + 1, 0).day;
}


extension DateAndTime on DateTime {

  Time get toTime => Time(hour, minute);
  Date get toDate => Date(year, month, day);
  Week get toWeek {
    final days = weekBeg.toDate % DateTime(year);
    return Week(year, (days < 0) ? 0 : days ~/ 7 + 1);
  }
  Month get toMonth => Month(year, month);

  String toISOCompact() => ''
      '${year.toString().padLeft(4, '0')}'
      '${month.toString().padLeft(2, '0')}'
      '${day.toString().padLeft(2, '0')}T'
      '${hour.toString().padLeft(2, '0')}'
      '${minute.toString().padLeft(2, '0')}'
      '${second.toString().padLeft(2, '0')}Z';

  String format(String fmt) => DateFormat(fmt).format(this);

  Date get tomorrow => toDate + 1;
  Date get yesterday => toDate - 1;

  DateTime get dayBeg => DateTime(year, month, day);
  DateTime get dayEnd => DateTime(year, month, day + 1);
  DateTime get weekBeg => DateTime(year, month, day - (weekday - 1));
  DateTime get weekEnd => DateTime(year, month, day + (8 - weekday));
  DateTime get monthBeg => DateTime(year, month);
  DateTime get monthEnd => DateTime(year, month + 1);
  DateTime get yearBeg => DateTime(year);
  DateTime get yearEnd => DateTime(year + 1, 1);
}
