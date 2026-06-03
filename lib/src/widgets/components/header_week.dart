import 'package:calendar/src/const.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:flutter/material.dart';


class WeekHeader extends StatelessWidget {
  final Week week;
  final int fromDay;
  final int toDay;
  final double? width;
  final double? height;
  final Color? background;
  final String? dateFormat;
  final double? datePadding;
  final TextStyle? dateStyle;

  const WeekHeader({
    super.key,
    required this.week,
    required this.fromDay,
    required this.toDay,
    this.width,
    this.height,
    this.background,
    this.dateFormat,
    this.datePadding,
    this.dateStyle,
  });

  List<Date> get dates {
    final dateList = <Date>[];
    var date = week.mon;
    for (int i = fromDay ; i <= toDay ; i++) {
      dateList.add(date + i - 1);
    }
    return dateList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: background,
        height: height,
        width: width,
        child: Row(
          children: [
            for (Date date in dates)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: datePadding ?? textHeaderPadding,
                  ),
                  child: Center(
                    child: Text(
                      date.format(dateFormat ?? dateHeaderFormat),
                      textAlign: TextAlign.center,
                      style: dateStyle,
                    ),
                  ),
                ),
              )
          ],
        )
    );
  }
}
