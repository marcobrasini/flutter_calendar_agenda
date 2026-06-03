import 'package:flutter/material.dart';
import 'package:calendar/src/utils/datetime.dart';
import '../../const.dart';


class TimeHeader extends StatelessWidget {
  final int fromHour;
  final int toHour;
  final int step;
  final double height;
  final double margin;
  final String timeFormat;
  final double? timePadding;
  final TextStyle? timeStyle;
  final Color? background;

  const TimeHeader({
    super.key,
    required this.fromHour,
    required this.toHour,
    required this.step,
    required this.height,
    required this.margin,
    required this.timeFormat,
    this.timePadding,
    this.timeStyle,
    this.background,
  });

  int get length => (toHour - fromHour) * Duration.minutesPerHour;

  Time get from => (fromHour == initialHour) ? Time.beg : Time(fromHour, 0);

  Time get to => (toHour == finalHour) ? Time.end : Time(toHour, 0);

  List<Time> get times {
    final timeList = <Time>[];
    var time = from.time as DateTime;
    while (time.isBefore(to)) {
      timeList.add(time.time);
      time = time.add(Duration(minutes: step));
    }
    timeList.add(to);
    return timeList;
  }

  List<double> get positions {
    final positionList = <double>[0.0];
    final delta = height / (times.length - 1);
    for (int i = 0; i < times.length - 1; i++) {
      positionList.add(positionList[i] + delta);
    }
    return positionList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      height: height + margin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (Time time in times)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: timePadding ?? textHeaderPadding,
              ),
              child: Text(
                time.format(timeFormat),
                style: timeStyle,
              ),
            ),
        ],
      )
    );
  }
}
