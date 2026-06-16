import 'package:calendar/src/data/fixture.dart';
import 'package:flutter/material.dart';
import '../frames/frame_weekly.dart';
import '../slots/slot_daily.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../data/source.dart';
import '../../data/event.dart';


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

  DateTime _startEvent(Event event, Offset local) {
    final step = timeScheme.round ?? 1;
    final minutes = (local.dy * timeScale / step).round() * step;
    final days = (local.dx * dateScale).round();
    final date = week.mon + (dateScheme.beg - 1) + days;
    final time = Time.fromHour(timeScheme.beg) + minutes;
    return date & time;
  }

  void onDrop(BuildContext context, Event event, Offset local) {
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

  List<Date> get dates {
    final dateList = <Date>[];
    var date = week.mon + (dateScheme.beg - 1);
    for (int i = 0 ; i < dateScheme.end ; i++) {
      dateList.add(date + i);
    }
    return dateList;
  }

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    // final events = source.forWeek(week);
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
          for (Date date in dates)
            DailySlot(
                events: source.forDate(date),
                width: width/dateScheme.count,
                height: height,
                timeScheme: timeScheme,
                callbacks: callbacks,
                onDrop: (Event event, Offset global) {
                  final box = context.findRenderObject() as RenderBox;
                  final local = box.globalToLocal(global);
                  onDrop(context, event, local);
                }
            ),
        ],
      ),
    );
  }
}
