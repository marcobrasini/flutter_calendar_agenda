import 'package:flutter_calendar_agenda/flutter_calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../sample_events.dart';

/// An event type with an extra field. Events are immutable, so the subclass
/// keeps its fields final and returns a new instance from `set`.
class Appointment extends Event {
  Appointment({
    required super.id,
    required super.start,
    required super.stop,
    required super.color,
    required super.subject,
    this.notes,
  });

  final String? notes;

  @override
  Appointment set(Map<String, dynamic> data) {
    final event = super.set(data);
    return Appointment(
      id: event.id,
      start: event.start,
      stop: event.stop,
      color: event.color,
      subject: event.subject,
      notes: data.containsKey('notes') ? data['notes'] as String? : notes,
    );
  }

  @override
  List<Object?> get props => [...super.props, notes];
}

/// A calendar typed on `Appointment`: callbacks receive the subclass directly.
class CustomEventExample extends StatefulWidget {
  const CustomEventExample({super.key});

  @override
  State<CustomEventExample> createState() => _CustomEventExampleState();
}

class _CustomEventExampleState extends State<CustomEventExample> {
  late final CalendarSource<Appointment> source;

  @override
  void initState() {
    super.initState();
    final now = sampleNow;
    source = CalendarSource<Appointment>(
      events: [
        Appointment(
          id: 'dentist',
          start: now,
          stop: now.add(const Duration(hours: 1)),
          color: Colors.blue,
          subject: 'Dentist',
          notes: 'Bring the X-rays',
        ),
        Appointment(
          id: 'call',
          start: now.add(const Duration(hours: 3)),
          stop: now.add(const Duration(hours: 3, minutes: 30)),
          color: Colors.pink,
          subject: 'Call with the supplier',
          notes: 'Ask about the delivery dates',
        ),
        Appointment(
          id: 'gym',
          start: now.add(const Duration(days: 1, hours: 9)),
          stop: now.add(const Duration(days: 1, hours: 10)),
          color: Colors.teal,
          subject: 'Gym',
        ),
      ],
    );
  }

  void _move(Appointment appointment, Fixture fixture) {
    source.modifyEvents([
      appointment.set({'start': fixture.start, 'stop': fixture.stop}),
    ]);
  }

  void _showNotes(Appointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              appointment.notes ?? 'No notes for "${appointment.subject}"')),
    );
  }

  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom event type')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Calendar<Appointment>(
          source: source,
          view: CalendarView.daily,
          timeScheme: const TimeScheme(6, 22, round: 10),
          onEventDragged: _move,
          onEventResized: _move,
          onEventTap: _showNotes,
        ),
      ),
    );
  }
}
