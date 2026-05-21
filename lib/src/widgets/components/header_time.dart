import 'package:flutter/material.dart';
import 'package:calendar/src/utils/datetime.dart';


class TimeHeader extends StatelessWidget {
  final int fromHour;
  final int toHour;
  final int step;
  final double offset;
  final double height;
  final double? width;
  final Color? background;
  final String timeFormat;
  final double? textPadding;
  final TextStyle? textStyle;

  const TimeHeader({
    super.key,
    required this.fromHour,
    required this.toHour,
    required this.step,
    required this.offset,
    required this.height,
    this.width,
    this.background,
    required this.timeFormat,
    this.textPadding,
    this.textStyle,
  });

  int get length => (toHour - fromHour) * 60;

  Time get from => (fromHour == 0) ? Time.beg : Time(fromHour, 0);

  Time get to => (toHour == 24) ? Time.end : Time(toHour, 0);

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
      height: height + offset,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (Time time in times)
            (textPadding == null)
                ? Text(time.format(timeFormat), style: textStyle)
                : Padding(
                  padding: EdgeInsets.symmetric(horizontal: textPadding!),
                  child: Text(time.format(timeFormat), style: textStyle),
                ),
        ],
      )
    );
  }
}
