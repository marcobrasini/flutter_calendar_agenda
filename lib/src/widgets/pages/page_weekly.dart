import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/source.dart';
import 'package:calendar/src/mixin.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/slot_event.dart';
import 'package:flutter/material.dart';


class WeeklyPage extends StatefulWidget with DateScheme, TimeScheme {

  const WeeklyPage({
    super.key,
    required this.week,
    required this.width,
    required this.height,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
  });

  final Week week;
  final double width;
  final double height;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  double get dayScale => days / width;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  double get timeScale => minutes / height;

  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}


class _WeeklyPageState extends State<WeeklyPage> {

  int x(Event event) => event.start.weekday - widget.begDay;
  int y(Event event) => event.start.time % Time.fromHour(widget.begHour);

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    final events = source.forWeek(widget.week);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          for (var event in events)
            Positioned(
              top: y(event) / widget.timeScale,
              left: x(event) / widget.dayScale,
              child: EventSlot(
                event: event,
                width: 1 / widget.dayScale,
                height: event.duration.inMinutes / widget.timeScale,
              ),
            )
        ],
      ),
    );
  }
}
