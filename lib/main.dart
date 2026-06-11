import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/pattern.dart';
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
            view: CalendarView.daily,
            begHour: 6,
            endHour: 22,
            begDay: 1,
            endDay: 6,
            // showHeaderView: false,
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
                start: now.add(Duration(hours: 26)),
                stop: now.add(Duration(hours: 27)),
                color:  Colors.yellow,
                subject: "Event",
              ),
              Event(
                id: "event3",
                start: now.add(Duration(hours: -23)),
                stop: now.add(Duration(hours: -22)),
                color:  Colors.deepOrange,
                subject: "Event",
              ),
              Event(
                id: "event4",
                start: now.add(Duration(days:-2)),
                stop: now.add(Duration(days:-2, hours: 1)),
                color:  Colors.pink,
                subject: "Rec",
                pattern: Pattern.fromICSString(
                    now.add(Duration(days:-2, hours: 1)),
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
