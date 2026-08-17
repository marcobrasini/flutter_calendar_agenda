import 'package:calendar/src/agenda.dart';
import 'package:calendar/src/config.dart';
import 'package:calendar/src/enums.dart';
import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool renew = true;

  @override
  Widget build(BuildContext context) {
    final now = (Date.now()) & Time(9, 0);
    final scheme = Theme.of(context).colorScheme;
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
      Event(
        id: "event8",
        start: now.add(Duration(days: 7, hours: 3, minutes: 30)),
        stop: now.add(Duration(days: 7, hours: 4, minutes: 30)),
        color:  Colors.green,
        subject: "Future",
      ),
      Event(
        id: "event9",
        start: now.add(Duration(days: -14, hours: 3, minutes: 30)),
        stop: now.add(Duration(days: -14, hours: 4, minutes: 30)),
        color:  Colors.grey,
        subject: "Past",
      ),
      Event(
        id: "event10",
        start: now.add(Duration(days: -26, hours: 6, minutes: 30)),
        stop: now.add(Duration(days: -26, hours: 8, minutes: 30)),
        color:  Colors.purple,
        subject: "Recurrence",
        pattern: Pattern(type: PatternType.weekly, count: 10),
      ),
      Event(
        id: "event11",
        start: now.add(Duration(days: -14)),
        stop: now.add(Duration(days: -14)),
        color:  Colors.amber,
        subject: "Close",
        pattern: Pattern(type: PatternType.weekly, count: 3, step: 2),
      ),
    ]);

    return MaterialApp(
      title: 'CalendarView.weekly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Weekly view"),
          actions: [
            IconButton(
                onPressed: () => setState(() {}),
                icon: Icon(Icons.refresh),
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Builder(
            builder: (context) {
              return Agenda(
                view: CalendarView.weekly,
                source: source,
                scroll: CalendarScroll.sequential,
                headerBuilder: (context, start, stop) => Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(start.format("dd MMMM yyyy"),
                        style: TextStyle(fontSize: 14),
                      ),
                      const Expanded(child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      )),
                      Text(stop.format("dd MMMM yyyy"),
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                eventConfig: EventConfig(extent: 60),
                eventBuilder: (context, event) => Center(
                  child: Text(event.subject,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                rightSwipeBuilder: (context) => ColoredBox(
                  color: scheme.secondaryContainer,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: scheme.onSecondaryContainer),
                          Text("Modify",
                            style: TextStyle(color: scheme.onSecondaryContainer),
                          )
                        ],
                      ),
                    )
                  ),
                ),
                leftSwipeBuilder: (context) => ColoredBox(
                  color: scheme.tertiaryContainer,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete, color: scheme.onTertiaryContainer),
                          Text("Delete",
                            style: TextStyle(color: scheme.onTertiaryContainer),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                onEventSwipedLeft: (event, fixture) {
                  print("left ${event.get()}");
                },
                onEventSwipedRight: (event, fixture) {
                  print("right ${event.get()}");
                },
                // begDay: -2,
                // endDay: 3,
                // dateStep: 3,
              );
            }
          ),
        ),
      ),
    );
  }
}
