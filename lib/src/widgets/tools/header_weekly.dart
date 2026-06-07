import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../tools/slot_date.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';


class WeeklyHeader extends StatelessWidget {

  const WeeklyHeader({
    super.key,
    this.width,
    this.height,
    required this.week,
    required this.scheme,
  });

  final Week week;
  final double? width;
  final double? height;
  final DateScheme scheme;

  List<Date> get dates {
    final dateList = <Date>[];
    var date = week.mon + (scheme.beg - 1);
    for (int i = 0 ; i < scheme.beg ; i++) {
      dateList.add(date + i);
    }
    return dateList;
  }

  @override
  Widget build(BuildContext context) {
    final dateConfig = CalendarConfig.of(context)!.date!;
    final widgets = <Widget>[];
    for (Date date in dates) {
      widgets.add(Expanded(
          child: DateSlot(
            date: date,
            dateFormat: dateConfig.format,
            datePadding: dateConfig.padding,
            dateTextStyle: dateConfig.textStyle,
            dateBackground: dateConfig.background,
          )
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
