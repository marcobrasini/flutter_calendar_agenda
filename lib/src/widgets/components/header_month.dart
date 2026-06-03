import 'package:calendar/src/const.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:flutter/material.dart';


class MonthHeader extends StatelessWidget {
  final int fromDay;
  final int toDay;
  final double? width;
  final double? height;
  final Color? background;
  final String? dayFormat;
  final double? dayPadding;
  final TextStyle? dayStyle;

  const MonthHeader({
    super.key,
    required this.fromDay,
    required this.toDay,
    this.width,
    this.height,
    this.background,
    this.dayPadding,
    this.dayFormat,
    this.dayStyle,
  });

  List<Date> get dates {
    final dateList = <Date>[];
    var date = Week.weekDays as Date;
    for (int i = fromDay ; i <= toDay ; i++) {
      dateList.add(date + i - 1);
    }
    return dateList;
  }

  @override
  Widget build(BuildContext context) {
    final week = Week.weekDays;
    return Container(
      color: background,
      width: width,
      height: height,
      child: Row(
        children: [
          for (Date date in dates)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: dayPadding ?? textHeaderPadding,
                ),
                child: Center(
                  child: Text(
                    date.format(dayFormat ?? dayHeaderFormat),
                    textAlign: TextAlign.center,
                    style: dayStyle,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
