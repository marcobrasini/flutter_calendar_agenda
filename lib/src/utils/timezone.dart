import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
export 'package:timezone/timezone.dart' show TZDateTime;


abstract final class TimeZones {
  static bool _initialized = false;

  static Future<void> initialize([String? location]) async {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
    if (location != null) {
      tz.setLocalLocation(tz.getLocation(location));
    } else {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
    }
  }

  static void ensureInitialized() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  static tz.Location location([String? location]) =>
      location != null ? tz.getLocation(location) : tz.local;
}