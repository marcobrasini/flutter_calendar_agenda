import 'package:flutter/material.dart';
import '../components/slot_date.dart';
import '../../utils/datetime.dart';
import '../../mixin.dart';


class WeeklyHeader extends StatelessWidget with DateScheme {

  const WeeklyHeader({
    super.key,
    required this.week,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    required this.dateFormat,
    required this.datePadding,
    this.dateTextStyle,
    this.background,
    this.width,
    this.height,
  });

  final Week week;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  final String dateFormat;
  final double datePadding;
  final TextStyle? dateTextStyle;
  final Color? background;
  final double? width;
  final double? height;

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
            dateFormat: dateFormat,
            datePadding: datePadding,
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
