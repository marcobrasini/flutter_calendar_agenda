import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../sample_events.dart';

/// Daily time grid with all-day events, drag and resize.
class DailyViewExample extends StatefulWidget {
  const DailyViewExample({super.key});

  @override
  State<DailyViewExample> createState() => _DailyViewExampleState();
}

class _DailyViewExampleState extends State<DailyViewExample> {
  final source = CalendarSource<Event>(
    events: [...sampleAllDayEvents(), ...sampleEvents()],
  );

  void _move(Event event, Fixture fixture) {
    source.modifyEvents([
      event.set({'start': fixture.start, 'stop': fixture.stop}),
    ]);
  }

  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily view')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Calendar<Event>(
          source: source,
          view: CalendarView.daily,
          timeScheme: const TimeScheme(0, 24, round: 15),
          dateScheme: const DateScheme.weekly(),
          onEventDragged: _move,
          onEventResized: _move,
          onEventTap: (event) => debugPrint('tap ${event.subject}'),
        ),
      ),
    );
  }
}
