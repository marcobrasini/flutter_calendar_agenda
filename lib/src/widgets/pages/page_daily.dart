import 'package:flutter/material.dart';
import '../frames/frame_daily.dart';
import '../tools/slot_event.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/event.dart';
import '../../data/source.dart';
import '../../config.dart';


class DailyPage extends StatelessWidget {

  const DailyPage({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.timeScheme,
  });

  final Date date;       // <-- passata esplicitamente, non letta dal controller
  final double width;
  final double height;
  final TimeScheme timeScheme;

  double get timeScale => timeScheme.scale(height);

  int _yOf(Event event) => event.start.time % Time.fromHour(timeScheme.beg);

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    final events = source.forDate(date);
    return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            DailyFrame(
              width: width,
              height: height,
              timeScheme: timeScheme,
              dailyTap: (int) {},
            ),
            for (var event in events)
              Positioned(
                top: _yOf(event) / timeScale,
                child: EventSlot(
                  event: event,
                  width: width,
                  height: event.duration.inMinutes / timeScale,
                ),
              ),
          ],
        ),
    );
  }
}
