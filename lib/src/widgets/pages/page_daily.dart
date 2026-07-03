import 'package:flutter/material.dart';
import '../frames/frame_daily.dart';
import '../tools/indicator_time.dart';
import '../slots/slot_daily.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/source.dart';
import '../../data/event.dart';
import '../../data/fixture.dart';
import '../../config.dart';


class DailyPage extends StatelessWidget {

  const DailyPage({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.timeScheme,
    required this.callbacks,
  });

  final Date date;
  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final CallbackScheme callbacks;

  DateTime _dateTime(Offset local) {
    final step = timeScheme.round ?? 1;
    final minutes = (local.dy * timeScale / step).round() * step;
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
    // context.read<CalendarDragger>().setOffsetConverter(_dateTime);
    final config = CalendarConfig.of(context)!;
    final source = CalendarSource.of(context);
    final events = source.forDate(date);
    final offset = config.view.indicatorRadius;
    return SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            DailyFrame(
              width: width,
              height: height,
              timeScheme: timeScheme,
              onTap: (local, [_]) => callbacks.onFrameTap?.call(_dateTime(local)),
              onDoubleTap: (local, [_]) => callbacks.onFrameDoubleTap?.call(_dateTime(local)),
              onLongPress: (local, [_]) => callbacks.onFrameLongPress?.call(_dateTime(local)),
              onCreate: (local, [_]) => _onTapped(context, local),
            ),
            Positioned(
              left: offset,
              child: DailySlot(
                events: events,
                width: width - offset,
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
            ),
          ],
        ),
    );
  }
}
