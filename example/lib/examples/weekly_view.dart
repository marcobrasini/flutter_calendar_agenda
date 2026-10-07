import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../sample_events.dart';

/// Weekly time grid with drag, resize and taps on empty slots.
class WeeklyViewExample extends StatefulWidget {
  const WeeklyViewExample({super.key});

  @override
  State<WeeklyViewExample> createState() => _WeeklyViewExampleState();
}

class _WeeklyViewExampleState extends State<WeeklyViewExample> {
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
      appBar: AppBar(title: const Text('Weekly view')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Calendar<Event>(
          source: source,
          view: CalendarView.weekly,
          timeScheme: const TimeScheme(6, 22, round: 15),
          dateScheme: DateScheme.weekly(),
          weekScheme: WeekScheme.general(),
          eventConfig: EventConfig(maxLines: 1),
          onEventDragged: _move,
          onEventResized: _move,
          onEventTap: (event) => debugPrint('tap ${event.subject}'),
          onFrameTap: (datetime) => debugPrint('tap on empty slot at $datetime'),
        ),
      ),
    );
  }
}
