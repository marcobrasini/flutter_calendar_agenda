import 'package:calendar/src/config.dart';
import 'package:calendar/src/context.dart';
import 'package:calendar/src/utils/schemes.dart';
import 'package:flutter/material.dart';
import 'package:calendar/src/utils/datetime.dart';


class TimeHeader extends StatelessWidget {

  const TimeHeader({
    super.key,
    this.width,
    this.height,
    required this.scheme,
  });

  final double? width;
  final double? height;
  final TimeScheme scheme;

  List<Time> get times {
    final timeList = <Time>[];
    var time = scheme.from as DateTime;
    while (time.isBefore(scheme.to)) {
      timeList.add(time.time);
      time = time.add(Duration(minutes: scheme.step.minutes));
    }
    timeList.add(scheme.to);
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
