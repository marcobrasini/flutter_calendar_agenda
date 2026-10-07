import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../sample_events.dart';

/// Recurring events built from a `Pattern` or an RRULE, and dragging a series.
class RecurrencesExample extends StatefulWidget {
  const RecurrencesExample({super.key});

  @override
  State<RecurrencesExample> createState() => _RecurrencesExampleState();
}

class _RecurrencesExampleState extends State<RecurrencesExample> {
  late final CalendarSource<Event> source;

  @override
  void initState() {
    super.initState();
    final now = sampleNow;
    source = CalendarSource<Event>(
      events: [
        Event(
          id: 'rrule-weekly',
          start: now,
          stop: now.add(const Duration(hours: 1)),
          color: Colors.blue,
          subject: 'Weekly, 5 times (RRULE)',
          pattern: Pattern.fromICSString('RRULE:FREQ=WEEKLY;COUNT=5'),
        ),
        Event(
          id: 'every-four-days',
          start: now.add(const Duration(days: 3, hours: 6)),
          stop: now.add(const Duration(days: 3, hours: 7)),
          color: Colors.orange,
          subject: 'Every 4 days',
          pattern: Pattern(type: PatternType.daily, step: 4),
        ),
        Event(
          id: 'weekly-unlimited',
          start: now.add(const Duration(days: -2, hours: 2)),
          stop: now.add(const Duration(days: -2, hours: 3)),
          color: Colors.red,
          subject: 'Weekly, no end',
          pattern: Pattern(type: PatternType.weekly),
        ),
        Event(
          id: 'one-off',
          start: now.add(const Duration(hours: 4)),
          stop: now.add(const Duration(hours: 5)),
          color: Colors.green,
          subject: 'One-off',
        ),
      ],
    );
  }

  void _onDragged(Event event, Fixture fixture) {
    if (event.isInstance) {
      // Dragging an instance moves the whole series by the same offset.
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
      appBar: AppBar(title: const Text('Recurring events')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Calendar<Event>(
          source: source,
          view: CalendarView.weekly,
          dateScheme: DateScheme.weekly(),
          timeScheme: const TimeScheme(6, 22, round: 15),
          onEventDragged: _onDragged,
          onEventTap: (event) => debugPrint('tap ${event.subject}'),
        ),
      ),
    );
  }
}
