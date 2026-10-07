import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../sample_events.dart';

/// Agenda list with sequential scrolling, a custom header and swipe actions.
class AgendaViewExample extends StatefulWidget {
  const AgendaViewExample({super.key});

  @override
  State<AgendaViewExample> createState() => _AgendaViewExampleState();
}

class _AgendaViewExampleState extends State<AgendaViewExample> {
  late final CalendarSource<Event> source;

  @override
  void initState() {
    super.initState();
    final now = sampleNow;
    source = CalendarSource<Event>(
      events: [
        ...sampleEvents(),
        Event(
          id: 'next-week',
          start: now.add(const Duration(days: 7, hours: 3, minutes: 30)),
          stop: now.add(const Duration(days: 7, hours: 4, minutes: 30)),
          color: Colors.green,
          subject: 'Next week',
        ),
        Event(
          id: 'two-weeks-ago',
          start: now.add(const Duration(days: -14, hours: 3, minutes: 30)),
          stop: now.add(const Duration(days: -14, hours: 4, minutes: 30)),
          color: Colors.grey,
          subject: 'Two weeks ago',
        ),
        Event(
          id: 'weekly',
          start: now.add(const Duration(days: -26, hours: 6, minutes: 30)),
          stop: now.add(const Duration(days: -26, hours: 8, minutes: 30)),
          color: Colors.purple,
          subject: 'Weekly, 10 times',
          pattern: Pattern(type: PatternType.weekly, count: 10),
        ),
        Event(
          id: 'every-other-week',
          start: now.add(const Duration(days: -14)),
          stop: now.add(const Duration(days: -14)),
          color: Colors.amber,
          subject: 'Every other week, 3 times',
          pattern: Pattern(type: PatternType.weekly, count: 3, step: 2),
        ),
      ],
    );
  }

  void _delete(Event event) {
    if (event.isInstance) {
      // Instances are not stored: skip this occurrence in its series.
      final recurrence = source.find(event.parentId!);
      if (recurrence == null) return;
      source.modifyEvents([recurrence.addException(event.start)]);
    } else {
      source.removeEvents([event]);
    }
  }

  void _modify(Event event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modify "${event.subject}"')),
    );
  }

  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Agenda<Event>(
          source: source,
          view: CalendarView.weekly,
          scroll: CalendarScroll.sequential,
          negligibleAgenda: true,
          headerBuilder: (context, start, stop) => Row(
            children: [
              Text(start.format('dd MMMM yyyy')),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Divider(),
                ),
              ),
              Text(stop.format('dd MMMM yyyy')),
            ],
          ),
          eventConfig: EventConfig(extent: 60),
          eventBuilder: (context, event) => Center(
            child: Text(event.subject, style: const TextStyle(fontSize: 16)),
          ),
          rightSwipeBuilder: (context) => _SwipeBackground(
            icon: Icons.edit,
            label: 'Modify',
            background: scheme.secondaryContainer,
            foreground: scheme.onSecondaryContainer,
            alignment: Alignment.centerLeft,
          ),
          leftSwipeBuilder: (context) => _SwipeBackground(
            icon: Icons.delete,
            label: 'Delete',
            background: scheme.tertiaryContainer,
            foreground: scheme.onTertiaryContainer,
            alignment: Alignment.centerRight,
          ),
          onEventSwipedLeft: (event, fixture) => _delete(event),
          onEventSwipedRight: (event, fixture) => _modify(event),
        ),
      ),
    );
  }
}

/// Background revealed behind an agenda item while it is swiped.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.alignment,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
