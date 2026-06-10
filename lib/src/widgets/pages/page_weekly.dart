import 'package:flutter/material.dart';
import '../frames/frame_weekly.dart';
import '../tools/slot_event.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/event.dart';
import '../../data/source.dart';
import '../../config.dart';


class WeeklyPage extends StatelessWidget {

  const WeeklyPage({
    super.key,
    required this.week,
    required this.width,
    required this.height,
    required this.timeScheme,
    required this.dateScheme,
  });

  final Week week;
  final double width;
  final double height;
  final DateScheme dateScheme;
  final TimeScheme timeScheme;
  double get dateScale => dateScheme.scale(width);
  double get timeScale => timeScheme.scale(height);

  int x(Event event) => event.start.weekday - dateScheme.beg;
  int y(Event event) => event.start.time % Time.fromHour(timeScheme.beg);

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    final events = source.forWeek(week);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          WeeklyFrame(
            width: width,
            height: height,
            dateScheme: dateScheme,
            timeScheme: timeScheme,
          ),
          for (var event in events)
            Positioned(
              top: y(event) / timeScale,
              left: x(event) / dateScale,
              child: EventSlot(
                event: event,
                width: 1 / dateScale,
                height: event.duration.inMinutes / timeScale,
              ),
            ),
        ],
      ),
    );
  }
}
