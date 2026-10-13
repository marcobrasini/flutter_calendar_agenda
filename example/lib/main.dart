import 'package:flutter/material.dart';

import 'examples/agenda_view.dart';
import 'examples/custom_event.dart';
import 'examples/daily_view.dart';
import 'examples/monthly_view.dart';
import 'examples/recurrences.dart';
import 'examples/weekly_view.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar examples',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const ExampleList(),
    );
  }
}

class ExampleList extends StatelessWidget {
  const ExampleList({super.key});

  static final _examples = <(String, String, WidgetBuilder)>[
    (
      'Agenda',
      'Sequential scrolling and swipe actions.',
      (_) => const AgendaViewExample()
    ),
    (
      'Daily view',
      'All-day events, drag and resize.',
      (_) => const DailyViewExample()
    ),
    (
      'Weekly view',
      'Time grid with frame taps.',
      (_) => const WeeklyViewExample()
    ),
    (
      'Monthly view',
      'Month grid with a recurring event.',
      (_) => const MonthlyViewExample()
    ),
    (
      'Recurring events',
      'Patterns, RRULE and dragging a series.',
      (_) => const RecurrencesExample()
    ),
    (
      'Custom event type',
      'Subclassing Event with extra fields.',
      (_) => const CustomEventExample()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar examples')),
      body: ListView(
        children: [
          for (final (title, subtitle, builder) in _examples)
            ListTile(
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: builder)),
            ),
        ],
      ),
    );
  }
}
