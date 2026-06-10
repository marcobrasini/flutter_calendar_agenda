import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/slot_date.dart';
import '../../utils/datetime.dart';
import '../../utils/schemes.dart';
import '../../controller.dart';
import '../../config.dart';



class WeeklyHeader extends StatelessWidget {

  const WeeklyHeader({
    super.key,
    this.width,
    this.height,
    required this.scheme,
  });

  final double? width;
  final double? height;
  final DateScheme scheme;

  List<Date> dates(Week week) {
    final dateList = <Date>[];
    var date = week.mon + (scheme.beg - 1);
    for (int i = 0 ; i < scheme.end ; i++) {
      dateList.add(date + i);
    }
    return dateList;
  }

  @override
  Widget build(BuildContext context) {
    final dateConfig = CalendarConfig.of(context)!.date!;
    final controller = context.watch<CalendarController>();
    final widgets = <Widget>[];
    for (Date date in dates(controller.asWeek)) {
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
