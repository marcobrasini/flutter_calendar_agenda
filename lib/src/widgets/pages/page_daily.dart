import 'package:calendar/src/data/fixture.dart';
import 'package:flutter/material.dart';
import '../frames/frame_daily.dart';
import '../pages/page_drag.dart';
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
    required this.callbacks,
  });

  final Date date;       // <-- passata esplicitamente, non letta dal controller
  final double width;
  final double height;
  final TimeScheme timeScheme;
  double get timeScale => timeScheme.scale(height);
  final CallbackScheme callbacks;

  int _yOf(Event event) => event.start.time % Time.fromHour(timeScheme.beg);

  DateTime _startFromOffset(Offset localPosition, Event event) {
    final minutes = (localPosition.dy * timeScale).round();
    final time = Time.fromHour(timeScheme.beg) + minutes;
    return date & time;
  }

  void _onDrop(BuildContext context, Event event, Offset localPosition) {
    final start = _startFromOffset(localPosition, event);
    if (start == event.start) return;
    callbacks.onDragAccepted?.call(
        event, Fixture(
            start: start,
            stop: start.add(event.duration))
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
            for (var event in events)
              Positioned(
                top: _yOf(event) / timeScale,
                child: EventSlot(
                  event: event,
                  width: width,
                  height: event.duration.inMinutes / timeScale,
                  onTap: callbacks.onEventTap,
                  onDoubleTap: callbacks.onEventDoubleTap,
                  onLongPress: callbacks.onEventLongPress,
                ),
              ),
            Positioned.fill(
              child: DragPage(
                onAccept: (event, localPosition) =>
                    _onDrop(context, event, localPosition),
              ),
            ),
          ],
        ),
    );
  }
}
