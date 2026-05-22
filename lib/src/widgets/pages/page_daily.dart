import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/slot_event.dart';
import 'package:flutter/material.dart';


class DailyPage extends StatefulWidget {
  final List<Event> events;
  final Date date;
  final double height;
  final double width;
  final double timeScale;

  const DailyPage({
    super.key,
    required this.date,
    required this.events,
    required this.width,
    required this.height,
    required this.timeScale,
  });

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {


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
                top: (event.start.time % widget.date) / widget.timeScale,
                child: EventSlot(
                  event: event,
                  width: widget.width,
                  height: event.duration.inMinutes / widget.timeScale,
                )
            )
        ],
      ),
    );
  }
}
