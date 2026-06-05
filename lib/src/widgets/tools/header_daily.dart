import 'package:calendar/src/config.dart';
import 'package:flutter/material.dart';
import '../tools/slot_date.dart';
import '../../utils/datetime.dart';


class DailyHeader extends StatelessWidget {

  const DailyHeader({
    super.key,
    this.width,
    this.height,
    required this.date,
  });

  final Date date;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final dateConfig = CalendarConfig.of(context)!.date!;
    return SizedBox(
      width: width,
      height: height,
      child: DateSlot(
        date: date,
        dateFormat: dateConfig.format,
        datePadding: dateConfig.padding,
        dateTextStyle: dateConfig.textStyle,
        dateBackground: dateConfig.background,
      ),
    );
  }
}
