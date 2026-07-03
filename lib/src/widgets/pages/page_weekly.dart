import 'package:flutter/material.dart';
import '../frames/frame_weekly.dart';
import '../tools/indicator_time.dart';
import '../slots/slot_daily.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/source.dart';
import '../../data/event.dart';
import '../../data/fixture.dart';
import '../../config.dart';


class WeeklyPage extends StatelessWidget {

  const WeeklyPage({
    super.key,
    required this.week,
    required this.width,
    required this.height,
    required this.timeScheme,
    required this.dateScheme,
    required this.callbacks,
  });

  final Week week;
  final double width;
  final double height;
  final DateScheme dateScheme;
  final TimeScheme timeScheme;
  double get dateScale => dateScheme.scale(width);
  double get timeScale => timeScheme.scale(height);
  final CallbackScheme callbacks;

  DateTime _dateTime(Offset local) {
    final step = timeScheme.round ?? 1;
    final minutes = (local.dy * timeScale / step).round() * step;
    final days = (local.dx * dateScale).round();
    final date = week.mon + (dateScheme.beg - 1) + days;
    final time = Time.fromHour(timeScheme.beg) + minutes;
    return date & time;
  }

  // void _onDropped(BuildContext context, Event event, Offset local) {
  //   final start = _dateTime(local);
  //   if (start == event.start) return;
  //   callbacks.onEventDragged?.call(
  //     event,
  //     Fixture(
  //       start: start,
  //       stop: start.add(event.duration),
  //     ),
  //   );
  // }

  void _onTapped(BuildContext context, Offset local) {
    final config = CalendarConfig.of(context)!;
    final start = _dateTime(local);
    callbacks.onEventCreated?.call(Fixture(
      start: start,
      stop: start.add(config.event.duration),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final source = CalendarSource.of(context);
    final space = width / dateScheme.count;
    final date = week.mon + (dateScheme.beg - 1);
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
            onTap: (local, [_]) => callbacks.onFrameTap?.call(_dateTime(local)),
            onDoubleTap: (local, [_]) => callbacks.onFrameDoubleTap?.call(_dateTime(local)),
            onLongPress: (local, [_]) => callbacks.onFrameLongPress?.call(_dateTime(local)),
            onCreate: (local, [_]) => _onTapped(context, local),
          ),
          for (int i = 0 ; i < dateScheme.count ; i++)
            Positioned(
              left: i * space,
              width: space,
              child: DailySlot(
                events: source.forDate(date + i),
                width: space,
                height: height,
                timeScheme: timeScheme,
                callbacks: callbacks,
              ),
            ),
          if (config.view.showIndicator) TimeIndicator(
            date: date,
            width: width,
            height: height,
            timeScheme: timeScheme,
            length: width/dateScheme.count,
          ),
        ],
      ),
    );
  }
}
