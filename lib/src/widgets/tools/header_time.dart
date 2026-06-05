import 'package:calendar/src/config.dart';
import 'package:calendar/src/context.dart';
import 'package:calendar/src/mixin.dart';
import 'package:flutter/material.dart';
import 'package:calendar/src/utils/datetime.dart';


class TimeHeader extends StatelessWidget with TimeScheme {

  const TimeHeader({
    super.key,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    this.width,
    this.height,
  });

  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  final double? width;
  final double? height;

  List<Time> get times {
    final timeList = <Time>[];
    var time = from as DateTime;
    while (time.isBefore(to)) {
      timeList.add(time.time);
      time = time.add(Duration(minutes: timeStep));
    }
    timeList.add(to);
    return timeList;
  }

  @override
  Widget build(BuildContext context) {
    final timeConfig = CalendarConfig.of(context)!.time!;
    final headerWidth = width;
    final headerHeight = height == null ? null : height! + context.timeMargin();
    return Container(
      width: headerWidth,
      height: headerHeight,
      color: timeConfig.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (Time time in times)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: timeConfig.padding,
              ),
              child: Text(
                time.format(timeConfig.format),
                textAlign: TextAlign.center,
                style: timeConfig.textStyle,
              ),
            ),
        ],
      )
    );
  }
}
