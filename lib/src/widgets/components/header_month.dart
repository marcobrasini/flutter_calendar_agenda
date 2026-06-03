import 'package:calendar/src/const.dart';
import 'package:calendar/src/mixin.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/slot_date.dart';
import 'package:flutter/material.dart';


class MonthHeader extends StatelessWidget with DateScheme {

  const MonthHeader({
    super.key,
    required this.month,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    this.width,
    this.height,
    this.background,
    this.weekFormat,
    this.weekPadding,
    this.weekTextStyle,
  });

  final Month month;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  final double? width;
  final double? height;
  final Color? background;
  final String? weekFormat;
  final double? weekPadding;
  final TextStyle? weekTextStyle;

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
    final widgets = <Widget>[];
    for (Date date in dates) {
      widgets.add(Expanded(
        child: DateSlot(
          date: date,
          dateFormat: weekFormat ?? weekHeaderFormat,
          datePadding: weekPadding ?? weekHeaderPadding,
          dateTextStyle: weekTextStyle,
          dateBackground: background,
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
