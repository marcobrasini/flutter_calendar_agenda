import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/slot_date.dart';
import '../../viewer.dart';
import '../../config.dart';


class DailyHeader extends StatelessWidget {

  const DailyHeader({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final dateConfig = CalendarConfig.of(context)!.date!;
    final viewer = context.watch<CalendarViewer>();
    return SizedBox(
      width: width,
      height: height,
      child: DateSlot(
        date: viewer.asDate,
        dateFormat: dateConfig.format,
        datePadding: dateConfig.padding,
        dateTextStyle: dateConfig.textStyle,
        dateBackground: dateConfig.background,
      ),
    );
  }
}
