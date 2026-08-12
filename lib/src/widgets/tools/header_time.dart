import 'package:calendar/src/const.dart';
import 'package:flutter/material.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../config.dart';
import '../../context.dart';


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
    final config = CalendarConfig.of(context);
    final format = config.time!.format ?? defaultTimeFormat;
    final headerWidth = width;
    final headerHeight = height == null ? null : height! + context.timeMargin();
    return Container(
      width: headerWidth,
      height: headerHeight,
      color: config.time!.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (Time time in times)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: config.time!.padding,
              ),
              child: Text(
                time.format(format),
                textAlign: TextAlign.center,
                style: config.time!.textStyle,
              ),
            ),
        ],
      ),
    );
  }
}
