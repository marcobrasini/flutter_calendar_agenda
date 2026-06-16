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

  DateTime _startEvent(Event event, Offset local) {
    final step = timeScheme.round ?? 1;
    final minutes = (local.dy * timeScale / step).round() * step;
    final time = Time.fromHour(timeScheme.beg) + minutes;
    return date & time;
  }

  void _onDrop(BuildContext context, Event event, Offset local) {
    final start = _startEvent(event, local);
    if (start == event.start) return;
    callbacks.onEventDragged?.call(
      event,
      Fixture(
        start: start,
        stop: start.add(event.duration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
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
              onTap: callbacks.onFrameTap,
              onDoubleTap: callbacks.onFrameDoubleTap,
              onLongPress: callbacks.onFrameLongPress,
            ),
            DailySlot(
              events: events,
              width: width,
              height: height,
              timeScheme: timeScheme,
              callbacks: callbacks,
              onDrop: (Event event, Offset global) {
                final box = context.findRenderObject() as RenderBox;
                final local = box.globalToLocal(global);
                _onDrop(context, event, local);
              }
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
