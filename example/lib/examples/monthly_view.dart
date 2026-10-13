import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../sample_events.dart';

/// Monthly grid with one-off events and a weekly recurring event.
class MonthlyViewExample extends StatefulWidget {
  const MonthlyViewExample({super.key});

  @override
  State<MonthlyViewExample> createState() => _MonthlyViewExampleState();
}

class _MonthlyViewExampleState extends State<MonthlyViewExample> {
  final source = CalendarSource<Event>(
    events: [
      ...sampleEvents(),
      Event(
        id: 'weekly',
        start: sampleNow.add(const Duration(days: -26, hours: 6, minutes: 30)),
        stop: sampleNow.add(const Duration(days: -26, hours: 8, minutes: 30)),
        color: Colors.purple,
        subject: 'Weekly, 10 times',
        pattern: Pattern(type: PatternType.weekly, count: 10),
      ),
    ],
  );

  void _onDragged(Event event, Fixture fixture) {
    if (event.isInstance) {
      // Shift the whole series by the same offset as the dragged instance.
      final recurrence = source.find(event.parentId!);
      if (recurrence == null) return;
      final offset = fixture.start.difference(event.start);
      source.modifyEvents([
        recurrence.set({
          'start': recurrence.start.add(offset),
          'stop': recurrence.stop.add(offset),
        }),
      ]);
    } else {
      source.modifyEvents([
        event.set({'start': fixture.start, 'stop': fixture.stop}),
      ]);
    }
  }

  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly view')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Calendar<Event>(
          source: source,
          view: CalendarView.monthly,
          weekScheme: WeekScheme.general(),
          onEventDragged: _onDragged,
          onEventTap: (event) => debugPrint('tap ${event.subject}'),
          onFrameTap: (date) => debugPrint('tap on $date'),
        ),
      ),
    );
  }
}
