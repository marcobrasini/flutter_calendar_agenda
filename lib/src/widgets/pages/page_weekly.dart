import 'package:calendar/src/modifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../frames/frame_weekly.dart';
import '../slots/slot_weekly.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/fixture.dart';
import '../../source.dart';
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

  DateTime converter(Offset local) {
    final step = timeScheme.round;
    final minutes = (local.dy * timeScale / step).round() * step;
    final days = (local.dx * dateScale).floor();
    final date = week.mon + (dateScheme.beg - 1) + days;
    final time = Time.fromHour(timeScheme.beg) + minutes;
    return date & time;
  }

  void _onTapped(BuildContext context, Offset local) {
    final config = CalendarConfig.of(context)!;
    final start = converter(local);
    callbacks.onEventCreated?.call(Fixture(
      start: start,
      stop: start.add(config.event.duration),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CalendarModifier>().attachConverter(converter);
    final source = context.watch<CalendarSource>();
    final config = CalendarConfig.of(context)!;
    final offset = config.view.indicatorRadius;
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
            onTap: (local, [_]) => callbacks.onFrameTap?.call(converter(local)),
            onDoubleTap: (local, [_]) => callbacks.onFrameDoubleTap?.call(converter(local)),
            onLongPress: (local, [_]) => callbacks.onFrameLongPress?.call(converter(local)),
            onCreate: (local, [_]) => _onTapped(context, local),
          ),
          Positioned(
            left: offset,
            child: WeeklySlot(
              events: [
                for (int i = 0 ; i < dateScheme.count ; i++)
                  source.forDate(date + i),
              ],
              width: width - offset,
              height: height,
              timeScheme: timeScheme,
              dateScheme: dateScheme,
              callbacks: callbacks,
            ),
          ),
        ],
      ),
    );
  }
}
