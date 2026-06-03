import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/pattern.dart';
import 'package:calendar/src/data/source.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/calendar.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return MaterialApp(
      title: 'Demo Griglia 2x2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Test")),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Calendar(
            view: CalendarView.weekly,
            fromHour: 6,
            toHour: 22,
            source: Source([
              Event(
                id: "event1",
                start: now,
                stop: now.add(Duration(hours: 1)),
                color:  Colors.green,
                subject: "Event",
              ),
              Event(
                id: "event2",
                start: now.add(Duration(days:2, hours: 1)),
                stop: now.add(Duration(days:2, hours: 2)),
                color:  Colors.pink,
                subject: "Events",
                pattern: Pattern.fromICSString(
                    now.add(Duration(days:2, hours: 1)),
                    "RRULE:FREQ=WEEKLY;COUNT=4;BYDAY=MO,FR;"
                ),
              )
            ]),
          ),
        )
      ),
    );
  }
}
