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
        pattern: Pattern.fromICSString("RRULE:FREQ=WEEKLY;COUNT=5;")
      ),
      Event(
        id: "event2",
        start: now.add(Duration(hours: 24*3 + 6)),
        stop: now.add(Duration(hours: 24*3 + 7)),
        color:  Colors.orange,
        subject: "After",
          pattern: Pattern(
            type: PatternType.daily,
            step: 4,
          )
      ),
      Event(
          id: "event3",
          start: now.add(Duration(hours: -24*2 + 2)),
          stop: now.add(Duration(hours: -24*2 + 3)),
          color:  Colors.red,
          subject: "Before",
          pattern: Pattern(
            type: PatternType.weekly,
            // recurrences: [now.date, now.date +3],
          )
      ),
      Event(
          id: "event4",
          start: now.add(Duration(hours: 4)),
          stop: now.add(Duration(hours: 5)),
          color:  Colors.green,
          subject: "Before",
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
              print(event.type);
              if (event.isInstance) {
                final recurrence = source.find(event.parentId!);
                final delta = fixture.start.difference(event.start);
                source.setEvent(recurrence.id!, {
                  "start": recurrence.start.add(delta),
                  "stop": recurrence.stop.add(delta)
                });
              } else {
                source.setEvent(event.id!, {
                  "start": fixture.start,
                  "stop": fixture.stop
                });
              }
              print("dragged $event -> $fixture");
            },
            onEventCreated: (fixture) {
              print("created $fixture");
            },
            onEventTap: (event) {
              print("tap $event");
            },
          ),
        )
      ),
    );
  }
}
