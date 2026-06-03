import 'package:calendar/src/const.dart';
import 'package:calendar/src/mixin.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/slot_date.dart';
import 'package:flutter/material.dart';


class WeekHeader extends StatelessWidget with DateScheme {

  const WeekHeader({
    super.key,
    required this.week,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    this.width,
    this.height,
    this.background,
    this.dateFormat,
    this.datePadding,
    this.dateTextStyle,
  });

  final Week week;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  final double? width;
  final double? height;
  final Color? background;
  final String? dateFormat;
  final double? datePadding;
  final TextStyle? dateTextStyle;

  List<Date> get dates {
    final dateList = <Date>[];
    var date = week.mon + (begDay - 1);
    for (int i = 0 ; i < days ; i++) {
      dateList.add(date + i);
    }
    return dateList;
  }

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (Date date in dates) {
      widgets.add(Expanded(
          child: DateSlot(
            date: date,
            dateFormat: dateFormat ?? dateHeaderFormat,
            datePadding: datePadding ?? dateHeaderPadding,
            dateTextStyle: dateTextStyle,
            dateBackground: background,
          )
      ));
    }
    return SizedBox(
        width: width,
        height: height,
        child: Row(
          children: widgets,
        )
    );
  }
}
