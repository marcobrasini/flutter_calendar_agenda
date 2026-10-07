import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:flutter/material.dart';

/// Today at 9:00, the reference time for all sample events.
DateTime get sampleNow => Date.now() & Time(9, 0);

/// A set of one-off events spread around today, shared by the view examples.
List<Event> sampleEvents() {
  final now = sampleNow;
  return [
    Event(id: 'now', start: now, stop: now.add(const Duration(hours: 1)), color: Colors.blue, subject: 'Now'),
    Event(id: 'next', start: now.add(const Duration(minutes: 45)), stop: now.add(const Duration(hours: 2, minutes: 45)), color: Colors.pink, subject: 'Next'),
    Event(id: 'later', start: now.add(const Duration(hours: 3, minutes: 30)), stop: now.add(const Duration(hours: 4, minutes: 30)), color: Colors.grey, subject: 'Later'),
    Event(id: 'yesterday', start: now.add(const Duration(hours: -25)), stop: now.add(const Duration(hours: -23)), color: Colors.teal, subject: 'Yesterday'),
    Event(id: 'tomorrow', start: now.add(const Duration(hours: 24)), stop: now.add(const Duration(hours: 25)), color: Colors.brown, subject: 'Tomorrow'),
    Event(id: 'tomorrow-late', start: now.add(const Duration(hours: 26)), stop: now.add(const Duration(hours: 28)), color: Colors.yellow, subject: 'Tomorrow, later'),
    Event(id: 'in-three-days', start: now.add(const Duration(days: 3, hours: 6)), stop: now.add(const Duration(days: 3, hours: 7)), color: Colors.orange, subject: 'In three days'),
  ];
}

/// A few all-day events, used by the daily and weekly examples.
List<Event> sampleAllDayEvents() {
  final today = Date.now();
  return [
    Event(id: 'all-day-today', start: today, color: Colors.blue, subject: 'All day, today'),
    Event(id: 'all-day-yesterday', start: today - 1, color: Colors.blue.shade200, subject: 'All day, yesterday'),
    Event(id: 'all-day-later', start: today + 2, color: Colors.blue.shade600, subject: 'All day, in two days'),
  ];
}
