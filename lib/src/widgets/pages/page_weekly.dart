import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/slot_event.dart';
import 'package:flutter/material.dart';


class WeeklyPage extends StatefulWidget {
  final List<Event> events;
  final Week week;
  final double height;
  final double width;
  final double timeScale;
  final double dateScale;
  final int fromHour;

  const WeeklyPage({
    super.key,
    required this.week,
    required this.events,
    required this.width,
    required this.height,
    required this.dateScale,
    required this.timeScale,
    required this.fromHour,
  });

  @override
  State<WeeklyPage> createState() => _WeeklyPageState();
}

class _WeeklyPageState extends State<WeeklyPage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          for (var event in widget.events)
            Positioned(
                left: (event.start.date % widget.week) / widget.dateScale,
                top: (event.start.time % event.start.date - (widget.fromHour * 60)) / widget.timeScale,
                child: EventSlot(
                  event: event,
                  width: 1 / widget.dateScale,
                  height: event.duration.inMinutes / widget.timeScale,
                )
            )
        ],
      ),
    );
  }
}
