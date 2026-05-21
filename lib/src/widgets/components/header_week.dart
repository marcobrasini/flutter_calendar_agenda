import 'package:calendar/src/utils/datetime.dart';
import 'package:flutter/material.dart';


class WeekHeader extends StatelessWidget {
  final Week week;
  final int fromDay;
  final int toDay;
  final int step;
  final double? height;
  final double? width;
  final Color? background;
  final String dateFormat;
  final double? datePadding;
  final TextStyle? dateStyle;
  final Widget? timeSlot;

  const WeekHeader({
    super.key,
    required this.week,
    required this.fromDay,
    required this.toDay,
    required this.step,
    this.height,
    this.width,
    this.background,
    required this.dateFormat,
    this.datePadding,
    this.dateStyle,
    this.timeSlot,
  });

  List<Date> get dates {
    final dateList = <Date>[];
    var date = week.date;
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
            if (timeSlot != null) timeSlot!,
            Expanded(
              child: Row(
                children: [
                  for (Date date in dates)
                    Expanded(
                      child: (datePadding == null)
                          ? Center(
                          child: Text(date.format(dateFormat),
                            textAlign: TextAlign.center,
                            style: dateStyle,
                          )
                      )
                          : Padding(
                        padding: EdgeInsets.symmetric(vertical: datePadding!),
                        child: Center(
                          child: Text(date.format(dateFormat),
                            textAlign: TextAlign.center,
                            style: dateStyle,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ],
        )
    );
  }
}
