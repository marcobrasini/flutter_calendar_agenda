import 'package:flutter_test/flutter_test.dart';
import 'package:calendar/src/data/fixture.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  final start = DateTime.now();
  final afterMinute = start.add(Duration(minutes: 1));
  final afterHour = start.add(Duration(hours: 1));
  final afterDay = start.add(Duration(days: 1));
  final afterWeek = start.add(Duration(days: 7));

  final fixTillDay = Fixture(start: start);
  final fixAllDay = Fixture(start: start.date);
  final fixMinute = Fixture(start: start, stop: afterMinute);
  final fixHour = Fixture(start: start, stop: afterHour);
  final fixDay = Fixture(start: start, stop: afterDay);
  final fixWeek = Fixture(start: start, stop: afterWeek);

  group('Fixture', () {
    test('constructor', () {
      expect(fixMinute.start, start);
      expect(fixMinute.stop, afterMinute);
      expect(fixHour.start, start);
      expect(fixHour.stop, afterHour);
      expect(fixDay.start, start);
      expect(fixDay.stop, afterDay);
      expect(fixWeek.start, start);
      expect(fixWeek.stop, afterWeek);
    });

    test('constructor allDay', () {
      expect(fixTillDay.start, start);
      expect(fixTillDay.stop, start.tomorrow);
      expect(fixAllDay.start, start.date);
      expect(fixAllDay.stop, start.tomorrow);
    });

    test('get', () {
      dynamic data;
      data = fixTillDay.get();
      expect(data, isA<Map<String, dynamic>>());
      expect(data["start"], start);
      expect(data["stop"], start.tomorrow);
      data = fixAllDay.get();
      expect(data, isA<Map<String, dynamic>>());
      expect(data["start"], start.date);
      expect(data["stop"], start.tomorrow);
      data = fixMinute.get();
      expect(data, isA<Map<String, dynamic>>());
      expect(data["start"], start);
      expect(data["stop"], afterMinute);
      data = fixHour.get();
      expect(data, isA<Map<String, dynamic>>());
      expect(data["start"], start);
      expect(data["stop"], afterHour);
      data = fixDay.get();
      expect(data, isA<Map<String, dynamic>>());
      expect(data["start"], start);
      expect(data["stop"], afterDay);
      data = fixWeek.get();
      expect(data, isA<Map<String, dynamic>>());
      expect(data["start"], start);
      expect(data["stop"], afterWeek);
    });

    test('set', () {
      final fixture = Fixture(start: DateTime(1));
      dynamic result;
      //
      result = fixture.set(fixTillDay.get());
      expect(result, isA<Fixture>());
      expect(result.start, start);
      expect(result.stop, start.tomorrow);
      //
      result = fixture.set(fixAllDay.get());
      expect(result, isA<Fixture>());
      expect(result.start, start.date);
      expect(result.stop, start.tomorrow);
      //
      result = fixture.set(fixMinute.get());
      expect(result, isA<Fixture>());
      expect(result.start, start);
      expect(result.stop, afterMinute);
      //
      result = fixture.set(fixHour.get());
      expect(result, isA<Fixture>());
      expect(result.start, start);
      expect(result.stop, afterHour);
      //
      result = fixture.set(fixDay.get());
      expect(result, isA<Fixture>());
      expect(result.start, start);
      expect(result.stop, afterDay);
      //
      result = fixture.set(fixWeek.get());
      expect(result, isA<Fixture>());
      expect(result.start, start);
      expect(result.stop, afterWeek);
    });

    test('duration', () {
      expect(fixMinute.duration, Duration(minutes: 1));
      expect(fixHour.duration, Duration(hours: 1));
      expect(fixDay.duration, Duration(days: 1));
      expect(fixWeek.duration, Duration(days: 7));
      expect(fixAllDay.duration, Duration(days: 1));
    });

    test('isSpanned', () {
      expect(fixMinute.isSpanned, false);
      expect(fixHour.isSpanned, false);
      expect(fixDay.isSpanned, true);
      expect(fixWeek.isSpanned, true);
    });

    test('isAllDay false', () {
      expect(fixMinute.isAllDay, false);
      expect(fixHour.isAllDay, false);
      expect(fixDay.isAllDay, false);
      expect(fixWeek.isAllDay, false);
    });

    test('isAllDay true', () {
      expect(Fixture(start: start.date, stop: afterMinute.tomorrow).isAllDay, true);
      expect(Fixture(start: start.date, stop: afterHour.tomorrow).isAllDay, true);
      expect(Fixture(start: start.date, stop: afterDay.tomorrow).isAllDay, true);
      expect(Fixture(start: start.date, stop: afterWeek.tomorrow).isAllDay, true);
    });

    test('hashCode', () {
        final copyMinute = Fixture(start: fixMinute.start, stop: fixMinute.stop);
        final copyHour = Fixture(start: fixHour.start, stop: fixHour.stop);
        final copyDay = Fixture(start: fixDay.start, stop: fixDay.stop);
        final copyWeek = Fixture(start: fixWeek.start, stop: fixWeek.stop);
        expect(fixMinute.hashCode, equals(copyMinute.hashCode));
        expect(fixHour.hashCode, equals(copyHour.hashCode));
        expect(fixDay.hashCode, equals(copyDay.hashCode));
        expect(fixWeek.hashCode, equals(copyWeek.hashCode));
    });

    test('operator ==', () {
      final copyMinute = Fixture(start: fixMinute.start, stop: fixMinute.stop);
      expect(fixMinute, equals(copyMinute));
      expect(fixMinute, isNot(equals(fixHour)));
      expect(fixMinute, isNot(equals(fixDay)));
      expect(fixMinute, isNot(equals(fixWeek)));
      final copyHour = Fixture(start: fixHour.start, stop: fixHour.stop);
      expect(fixHour, equals(copyHour));
      expect(fixHour, isNot(equals(fixMinute)));
      expect(fixHour, isNot(equals(fixDay)));
      expect(fixHour, isNot(equals(fixWeek)));
      final copyDay = Fixture(start: fixDay.start, stop: fixDay.stop);
      expect(fixDay, equals(copyDay));
      expect(fixDay, isNot(equals(fixMinute)));
      expect(fixDay, isNot(equals(fixHour)));
      expect(fixDay, isNot(equals(fixWeek)));
      final copyWeek = Fixture(start: fixWeek.start, stop: fixWeek.stop);
      expect(fixWeek, equals(copyWeek));
      expect(fixWeek, isNot(equals(fixMinute)));
      expect(fixWeek, isNot(equals(fixHour)));
      expect(fixWeek, isNot(equals(fixDay)));
    });
  });
}