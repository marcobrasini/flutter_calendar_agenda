import 'package:calendar/src/context.dart';
import 'package:calendar/src/mixin.dart';
import 'package:flutter/material.dart';
import 'package:calendar/src/utils/datetime.dart';
import '../../const.dart';

class TimeHeader extends StatelessWidget with TimeScheme {

  const TimeHeader({
    super.key,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    this.width,
    this.height,
    this.background,
    this.timeFormat,
    this.timePadding,
    this.timeTextStyle,
  });

  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  final double? width;
  final double? height;
  final Color? background;
  final String? timeFormat;
  final double? timePadding;
  final TextStyle? timeTextStyle;

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
    final margin = context.timeMargin(timeTextStyle);
    final headerWidth = width;
    final headerHeight = (height == null) ? null : height! + margin;
    return Container(
      width: headerWidth,
      height: headerHeight,
      color: background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (Time time in times)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: timePadding ?? textHeaderPadding,
              ),
              child: Text(
                time.format(timeFormat ?? timeHeaderFormat),
                textAlign: TextAlign.center,
                style: timeTextStyle,
              ),
            ),
        ],
      )
    );
  }
}
