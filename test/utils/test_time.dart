import 'package:test/test.dart';
import 'package:intl/intl.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final clock = Time.now();
  final now = DateTime.now();
  final hour = now.hour;
  final minute = now.minute;

  group('Time', () {
    test('Time now', () {
      expect(clock, isA<Time>());
      expect(clock.year, 1);
      expect(clock.month, 1);
      expect(clock.day, 1);
      expect(clock.hour, hour);
      expect(clock.minute, minute);
    });

    test('Time constructor', () {
      final time = Time(hour, minute);
      expect(time, isA<Time>());
      expect(time.year, 1);
      expect(time.month, 1);
      expect(time.day, 1);
      expect(time.hour, hour);
      expect(time.minute, minute);
    });

    test('Time from DateTime constructor', () {
      final time = now.toTime;
      expect(time, isA<Time>());
      expect(time.year, 1);
      expect(time.month, 1);
      expect(time.day, 1);
      expect(time.hour, hour);
      expect(time.minute, minute);
    });

    test('Time as DateTime constructor', () {
      final datetime = clock as DateTime;
      expect(datetime, isA<DateTime>());
      expect(datetime.year, 1);
      expect(datetime.month, 1);
      expect(datetime.day, 1);
      expect(datetime.hour, hour);
      expect(datetime.minute, minute);
    });

    test('Time toString', () {
      final time = Time(hour, minute);
      final string = DateFormat("HH:mm").format(now);
      expect(time.toString(), string);
    });

    test('Time fromString', () {
      final string = now.toString();
      final time = Time.fromString(string.split(' ')[1].split('.')[0]);
      expect(time.hour, hour);
      expect(time.minute, minute);
    });

    test('Time operator ==', () {
      final after = now.add(Duration(minutes: 1));
      final before = now.add(Duration(minutes: -1));
      expect(clock == now, true);
      expect(clock == after, false);
      expect(clock == before, false);
    });

    test('Time operator <', () {
      expect(clock < now, false);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock < afterMinute, true);
      expect(clock < beforeMinute, false);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock < afterHour, true);
      expect(clock < beforeHour, false);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock < after, true);
      expect(clock < before, false);
    });

    test('Time operator >', () {
      expect(clock > now, false);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock > afterMinute, false);
      expect(clock > beforeMinute, true);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock > afterHour, false);
      expect(clock > beforeHour, true);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock > after, false);
      expect(clock > before, true);
    });

    test('Time operator <=', () {
      expect(clock <= now, true);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock <= afterMinute, true);
      expect(clock <= beforeMinute, false);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock <= afterHour, true);
      expect(clock <= beforeHour, false);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock <= after, true);
      expect(clock <= before, false);
    });

    test('Time operator >=', () {
      expect(clock >= now, true);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock >= afterMinute, false);
      expect(clock >= beforeMinute, true);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock >= afterHour, false);
      expect(clock >= beforeHour, true);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock >= after, false);
      expect(clock >= before, true);
    });

    test('Date operator +', () {
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock + 1 == afterMinute, true);
      expect(clock + -1 == beforeMinute, true);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock + 60 == afterHour, true);
      expect(clock + -60 == beforeHour, true);
      final afterDay = now.add(Duration(days: 1));
      final beforeDay = now.add(Duration(days: -1));
      expect(clock + 60*24 == afterDay, true);
      expect(clock + -60*24 == beforeDay, true);
      final after = now.add(Duration(days: 1, hours: 1, minutes: 1));
      final before = now.add(Duration(days: -1, hours: -1, minutes: -1));
      expect(clock + (60*24 + 60 + 1) == after, true);
      expect(clock + (-60*24 - 60 - 1) == before, true);
    });

    test('Date operator -', () {
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock - -1 == afterMinute, true);
      expect(clock - 1 == beforeMinute, true);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock - -60 == afterHour, true);
      expect(clock - 60 == beforeHour, true);
      final afterDay = now.add(Duration(days: 1));
      final beforeDay = now.add(Duration(days: -1));
      expect(clock - -60*24 == afterDay, true);
      expect(clock - 60*24 == beforeDay, true);
      final after = now.add(Duration(days: 1, hours: 1, minutes: 1));
      final before = now.add(Duration(days: -1, hours: -1, minutes: -1));
      expect(clock - (-60*24 - 60 - 1) == after, true);
      expect(clock - (60*24 + 60 + 1) == before, true);
    });

    test('Time operator %', () {
      expect(clock % now, 0);
      final afterMinute = now.add(Duration(minutes: 1));
      final beforeMinute = now.add(Duration(minutes: -1));
      expect(clock % afterMinute, -1);
      expect(clock % beforeMinute, 1);
      final afterHour = now.add(Duration(hours: 1));
      final beforeHour = now.add(Duration(hours: -1));
      expect(clock % afterHour, -60);
      expect(clock % beforeHour, 60);
      final after = now.add(Duration(hours: 1, minutes: -1));
      final before = now.add(Duration(hours: -1, minutes: 1));
      expect(clock % after, -59);
      expect(clock % before, 59);
    });
  });
}
