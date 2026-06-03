import 'package:flutter/material.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/source.dart';
import '../components/slot_event.dart';
import '../../utils/datetime.dart';
import '../../mixin.dart';


class DailyPage extends StatefulWidget with TimeScheme {

  const DailyPage({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
  });

  final Date date;
  final double width;
  final double height;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  double get timeScale => minutes / height;

  @override
  State<DailyPage> createState() => _DailyPageState();
}


class _DailyPageState extends State<DailyPage> {

  int y(Event event) => event.start.time % Time.fromHour(widget.begHour);

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    final events = source.forDate(widget.date);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          for (var event in events)
            Positioned(
              top: y(event) / widget.timeScale,
              child: EventSlot(
                event: event,
                width: widget.width,
                height: event.duration.inMinutes / widget.timeScale,
              ),
            )
        ],
      ),
    );
  }
}
