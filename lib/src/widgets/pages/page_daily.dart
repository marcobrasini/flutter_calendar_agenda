import 'package:calendar/src/data/fixture.dart';
import 'package:calendar/src/widgets/slots/slot_daily.dart';
import 'package:flutter/material.dart';
import '../frames/frame_daily.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/source.dart';
import '../../data/event.dart';


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
    final minutes = (local.dy * timeScale).round();
    final time = Time.fromHour(timeScheme.beg) + minutes;
    return date & time;
  }

  void _onDrop(BuildContext context, Event event, Offset local) {
    final start = _startEvent(event, local);
    if (start == event.start) return;
    callbacks.onDragAccepted?.call(
      event,
      Fixture(
        start: start,
        stop: start.add(event.duration),
      ),
    );
  }

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
          ],
        ),
    );
  }
}
