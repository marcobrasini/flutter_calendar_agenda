import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/source.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/slot_event.dart';
import 'package:flutter/material.dart';


class MonthlyPage extends StatefulWidget {
  final List<Event> events;
  final Month month;
  final double width;
  final double height;
  final double dayScale;
  final double weekScale;
  final int fromDay;

  const MonthlyPage({
    super.key,
    required this.month,
    required this.events,
    required this.width,
    required this.height,
    required this.dayScale,
    required this.weekScale,
    required this.fromDay,
  });

  @override
  State<MonthlyPage> createState() => _MonthlyPageState();
}


class _MonthlyPageState extends State<MonthlyPage> {

  int x(Event event) => event.start.weekday - widget.fromDay;
  int y(Event event) => event.start.date % (widget.month.weekStart as Date) ~/ 7;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          for (var event in widget.events)
            Positioned(
              top: y(event) / widget.weekScale,
              left: x(event) / widget.dayScale,
              child: EventSlot(
                event: event,
                width: 1 / widget.dayScale,
                height: event.duration.inMinutes / widget.weekScale,
              ),
            )
        ],
      ),
    );
  }
}
