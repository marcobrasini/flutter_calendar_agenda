import 'package:calendar/src/data/fixture.dart';
import 'package:flutter/material.dart';
import '../frames/frame_weekly.dart';
import '../pages/page_drag.dart';
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

  int _xOf(Event event) => event.start.weekday - dateScheme.beg;
  int _yOf(Event event) => event.start.time % Time.fromHour(timeScheme.beg);

  DateTime _startFromOffset(Offset localPosition, Event event) {
    final days = (localPosition.dx * dateScale).round();
    final minutes = (localPosition.dy * timeScale).round();
    final date = week.mon + (dateScheme.beg - 1) + days;
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
            onTap: callbacks.onFrameTap,
            onDoubleTap: callbacks.onFrameDoubleTap,
            onLongPress: callbacks.onFrameLongPress,
          ),
          for (var event in events)
            Positioned(
              top: _yOf(event) / timeScale,
              left: _xOf(event) / dateScale,
              child: EventSlot(
                event: event,
                width: 1 / dateScale,
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
