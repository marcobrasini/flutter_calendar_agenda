import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/calendar.dart';
import 'package:calendar/src/source.dart';
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
    final source = CalendarSource([
      Event(
        id: "event2",
        start: now,
        stop: now.add(Duration(hours: 1)),
        color:  Colors.blue,
        subject: "Occurrence",
      ),
      Event(
        id: "event3",
        start: now.add(Duration(minutes: 45)),
        stop: now.add(Duration(hours: 2, minutes: 45)),
        color:  Colors.pink,
        subject: "Occurrence",
      ),
      Event(
        id: "event",
        start: now.add(Duration(hours: 24)),
        stop: now.add(Duration(hours: 24, minutes: 30)),
        color:  Colors.blue,
        subject: "Occurrence",
      ),
      Event(
        id: "event4",
        start: now.add(Duration(hours: -24, minutes: 30)),
        stop: now.add(Duration(hours: -23)),
        color:  Colors.pink,
        subject: "Other",
      ),
      Event(
        id: "event1",
        start: now.add(Duration(hours: 24*3 + 6)),
        stop: now.add(Duration(hours: 24*3 + 7)),
        color:  Colors.green,
        subject: "Occurrence",
      ),
      Event(
        id: "event5",
        start: now.add(Duration(hours: 24 +2)),
        stop: now.add(Duration(hours: 24 +4)),
        color:  Colors.yellow,
        subject: "Case",
      ),
      Event(
        id: "event6",
        start: now.add(Duration(hours: 3, minutes: 30)),
        stop: now.add(Duration(hours: 4, minutes: 30)),
        color:  Colors.grey,
        subject: "Case",
      ),
    ]);
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
            // timeRatio: 0.0,
            timeRound: 15,
            begHour: 6,
            endHour: 22,
            begDay: 1,
            endDay: 7,
            source: source,
            onEventDragged: (event, fixture) {
              source.setEvent(event.id!, {
                "start": fixture.start,
                "stop": fixture.stop
              });
              print("dragged $event -> $fixture");
            },
            onEventResized:  (event, fixture) {
              source.setEvent(event.id!, {
                "start": fixture.start,
                "stop": fixture.stop
              });
              print("resized $event -> $fixture");
            },
            onEventCreated: (fixture) {
              print("created $fixture");
            },
            onEventTap: (event) {
              print("tap $event");
            },
            // showIndicator: false,
            // timeBackground: Colors.grey.shade200,
            // dateBackground: Colors.grey.shade200,
          ),
        )
      ),
    );
  }
}
