import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:calendar/src/calendar.dart';
import 'package:calendar/src/enums.dart';
import 'package:calendar/src/source.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/utils/datetime.dart';


class Appointment extends Event {
  Appointment({
    required super.id,
    required super.start,
    required super.stop,
    required super.color,
    required super.subject,
    this.infos,
  });

  @override
  Appointment set(Map<String, dynamic> data) {
    super.set(data);
    return this;
  }

  String? infos;
}


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final now = Date.now() & Time(9, 0);
    final source = CalendarSource<Appointment>(events: [
      Appointment(
        id: "event1",
        start: now,
        stop: now.add(Duration(hours: 1)),
        color:  Colors.blue,
        subject: "Now",
        infos: "infos_now_event1",
      ),
      Appointment(
        id: "event2",
        start: now.add(Duration(minutes: 45)),
        stop: now.add(Duration(hours: 2, minutes: 45)),
        color:  Colors.pink,
        subject: "Next",
        infos: "infos_next_event2",
      ),
      Appointment(
        id: "event3",
        start: now.add(Duration(hours: 24)),
        stop: now.add(Duration(hours: 25)),
        color:  Colors.brown,
        subject: "Tomorrow",
        infos: "infos_tomorrow_event3",
      ),
      Appointment(
        id: "event4",
        start: now.add(Duration(hours: -25)),
        stop: now.add(Duration(hours: -23)),
        color:  Colors.teal,
        subject: "Yesterday",
        infos: "infos_yesterday_event4",
      ),
      Appointment(
        id: "event5",
        start: now.add(Duration(hours: 24*3 + 6)),
        stop: now.add(Duration(hours: 24*3 + 7)),
        color:  Colors.orange,
        subject: "After",
        infos: "infos_after_event5",
      ),
      Appointment(
        id: "event6",
        start: now.add(Duration(hours: 24 + 2)),
        stop: now.add(Duration(hours: 24 + 4)),
        color:  Colors.yellow,
        subject: "Before",
        infos: "infos_before_event6",
      ),
      Appointment(
        id: "event7",
        start: now.add(Duration(hours: 3, minutes: 30)),
        stop: now.add(Duration(hours: 4, minutes: 30)),
        color:  Colors.grey,
        subject: "Later",
        infos: "infos_later_event7",
      ),
    ]);

    return MaterialApp(
      title: 'CalendarView.weekly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Appointment")),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Calendar<Appointment>(
            source: source,
            view: CalendarView.weekly,
            timeScheme: TimeScheme(6, 22, round: 10),
            onEventDragged: (event, fixture) {
              source.modifyEvents([event.set({
                "start": fixture.start,
                "stop": fixture.stop
              })]);
              print("dragged $event with ${event.infos} -> $fixture");
            },
            onEventResized:  (event, fixture) {
              source.modifyEvents([event.set({
                "start": fixture.start,
                "stop": fixture.stop
              })]);
              print("resized $event with ${event.infos} -> $fixture");
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
