import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../tools/slot_date.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';


class MonthlyHeader extends StatelessWidget {

  const MonthlyHeader({
    super.key,
    this.width,
    this.height,
    required this.month,
    required this.scheme,
  });

  final Month month;
  final DateScheme scheme;
  final double? width;
  final double? height;

  List<Date> get dates {
    final dateList = <Date>[];
    var date = Week.weekDays.mon + (scheme.beg - 1);
    for (int i = 0 ; i < scheme.count ; i++) {
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
