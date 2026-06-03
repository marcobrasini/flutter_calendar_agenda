import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/slot_event.dart';
import 'package:flutter/material.dart';


class DailyPage extends StatefulWidget {
  final List<Event> events;
  final Date date;
  final double width;
  final double height;
  final double timeScale;
  final int fromHour;

  const DailyPage({
    super.key,
    required this.date,
    required this.events,
    required this.width,
    required this.height,
    required this.timeScale,
    required this.fromHour,
  });

  @override
  State<DailyPage> createState() => _DailyPageState();
}


class _DailyPageState extends State<DailyPage> {

  int y(Event event) => event.start.time % Time(widget.fromHour, 0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          for (var event in widget.events)
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
