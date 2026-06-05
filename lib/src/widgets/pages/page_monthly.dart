import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/header_monthly.dart';
import '../../utils/datetime.dart';
import '../../data/event.dart';
import '../../controller.dart';
import '../../config.dart';
import '../../const.dart';
import '../../mixin.dart';
import 'page_gesture.dart';
import 'page_slot.dart';


class MonthlyPage extends StatelessWidget with WeekScheme, DateScheme {

  const MonthlyPage({
    super.key,
    required this.width,
    required this.height,
    required this.padding,
    required this.begWeek,
    required this.endWeek,
    required this.weekStep,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
  });

  final double width;
  final double height;
  final double padding;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  double get dayScale => days / width;
  @override final int begWeek;
  @override final int endWeek;
  @override final int weekStep;
  double get weekScale => weeks / height;

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final controller = context.watch<CalendarController>();
    final month = controller.dateTime as Month;
    final start = month.weekStart.date;
    final headerPage = MonthlyHeader(
      month: month,
      width: width,
      begDay: begDay,
      endDay: endDay,
      dateStep: dateStep,
    );
    final slotPainter = Column(
      children: [
        for (int i = 0; i < weeks; i++)
          Row(
            children: [
              for (int j = 0; j < days; j++)
                SlotPage(
                  date: start + (i * stepWeek + j) + (begDay - 1),
                  width: width / days,
                  height: height / weeks,
                ),
            ],
          )
      ],
    );
    return Column(
      children: [
        if (config.view.showHeader) headerPage,
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            vertical: padding,
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                slotPainter,
                SwipePage(
                  last: controller.last,
                  next: controller.next,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
