import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/source.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/calendar.dart';
import 'package:flutter/material.dart';
import 'package:calendar/src/utils/datetime.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final now = Date.now() & Time(9, 0);
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
            begHour: 6,
            endHour: 22,
            begDay: 1,
            endDay: 6,
            source: Source([
              Event(
                id: "event2",
                start: now,
                stop: now.add(Duration(hours: 1)),
                color:  Colors.blue,
                subject: "Occurrence",
              ),
              Event(
                id: "event",
                start: now,
                stop: now.add(Duration(minutes: 30)),
                color:  Colors.blue,
                subject: "Occurrence",
              ),
              Event(
                id: "event",
                start: now.add(Duration(minutes: 30)),
                stop: now.add(Duration(hours: 1)),
                color:  Colors.pink,
                subject: "Other",
              ),
              Event(
                id: "event1",
                start: now,
                stop: now.add(Duration(hours: 3)),
                color:  Colors.green,
                subject: "Occurrence",
              ),
              Event(
                id: "event3",
                start: now.add(Duration(hours: 2)),
                stop: now.add(Duration(hours: 4)),
                color:  Colors.yellow,
                subject: "Case",
              ),
              Event(
                id: "event4",
                start: now.add(Duration(hours: 3, minutes: 30)),
                stop: now.add(Duration(hours: 4, minutes: 30)),
                color:  Colors.grey,
                subject: "Case",
              ),
            ]),
          ),
        )
      ),
    );
  }
}
