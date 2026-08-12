import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final now = Date.now() & Time(9, 0);
    final source = CalendarSource(events: [
      Event(
        id: "event1",
        start: now,
        stop: now.add(Duration(hours: 1)),
        color:  Colors.blue,
        subject: "Now",
      ),
      Event(
        id: "event2",
        start: now.add(Duration(minutes: 45)),
        stop: now.add(Duration(hours: 2, minutes: 45)),
        color:  Colors.pink,
        subject: "Next",
      ),
      Event(
        id: "event3",
        start: now.add(Duration(hours: 24)),
        stop: now.add(Duration(hours: 25)),
        color:  Colors.brown,
        subject: "Tomorrow",
      ),
      Event(
        id: "event4",
        start: now.add(Duration(hours: -25)),
        stop: now.add(Duration(hours: -23)),
        color:  Colors.teal,
        subject: "Yesterday",
      ),
      Event(
        id: "event5",
        start: now.add(Duration(hours: 24*3 + 6)),
        stop: now.add(Duration(hours: 24*3 + 7)),
        color:  Colors.orange,
        subject: "After",
      ),
      Event(
        id: "event6",
        start: now.add(Duration(hours: 24 + 2)),
        stop: now.add(Duration(hours: 24 + 4)),
        color:  Colors.yellow,
        subject: "Before",
      ),
      Event(
        id: "event7",
        start: now.add(Duration(hours: 3, minutes: 30)),
        stop: now.add(Duration(hours: 4, minutes: 30)),
        color:  Colors.grey,
        subject: "Later",
      ),
    ]);

    return MaterialApp(
      title: 'CalendarView.weekly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Weekly view")),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Calendar(
            source: source,
            view: CalendarView.weekly,
            timeRound: 15,
            begHour: 6,
            endHour: 22,
            onEventDragged: (event, fixture) {
              source.modifyEvent(event.set({
                "start": fixture.start,
                "stop": fixture.stop
              }));
              print("dragged $event -> $fixture");
            },
            onEventResized:  (event, fixture) {
              source.modifyEvent(event.set({
                "start": fixture.start,
                "stop": fixture.stop
              }));
              print("resized $event -> $fixture");
            },
            onEventTap: (event) {
              print("tap $event");
            },
            onFrameTap: (datetime) {
              print("tap $datetime");
            },
          ),
        )
      ),
    );
  }
}
