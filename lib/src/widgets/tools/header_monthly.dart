import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../tools/slot_date.dart';
import '../../utils/datetime.dart';
import '../../mixin.dart';


class MonthlyHeader extends StatelessWidget with DateScheme {

  const MonthlyHeader({
    super.key,
    this.width,
    this.height,
    required this.month,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
  });

  final Month month;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  final double? width;
  final double? height;

  List<Date> get dates {
    final dateList = <Date>[];
    var date = Week.weekDays.mon + (begDay - 1);
    for (int i = 0 ; i < days ; i++) {
      dateList.add(date + i);
    }
    return dateList;
  }

  @override
  Widget build(BuildContext context) {
    final weekConfig = CalendarConfig.of(context)!.week!;
    final widgets = <Widget>[];
    for (Date date in dates) {
      widgets.add(Expanded(
        child: DateSlot(
          date: date,
          dateFormat: weekConfig.format,
          datePadding: weekConfig.padding,
          dateTextStyle: weekConfig.textStyle,
          dateBackground: weekConfig.background,
        ),
      ));
    }
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        children: widgets,
      ),
    );
  }
}
