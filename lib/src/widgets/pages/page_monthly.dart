import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tools/header_monthly.dart';
import '../../utils/datetime.dart';
import '../../data/event.dart';
import '../../controller.dart';
import '../../config.dart';
import '../../const.dart';
import '../../utils/schemes.dart';
import 'page_gesture.dart';
import 'page_slot.dart';


class MonthlyPage extends StatelessWidget {

  const MonthlyPage({
    super.key,
    required this.width,
    required this.height,
    required this.padding,
    required this.dateScheme,
    required this.weekScheme,
  });

  final double width;
  final double height;
  final double padding;
  final DateScheme dateScheme;
  final WeekScheme weekScheme;
  double get dateScale => dateScheme.scale(width);
  double get weekScale => weekScheme.scale(height);

  @override
  Widget build(BuildContext context) {
    final config = CalendarConfig.of(context)!;
    final controller = context.watch<CalendarController>();
    final month = controller.dateTime as Month;
    final start = month.weekStart.date;
    final headerPage = MonthlyHeader(
      month: month,
      width: width,
      scheme: dateScheme,
    );
    final slotPainter = Column(
      children: [
        for (int i = 0; i < weekScheme.count; i++)
          Row(
            children: [
              for (int j = 0; j < dateScheme.count; j++)
                SlotPage(
                  date: start + (i * weekScheme.count + j) + (dateScheme.beg - 1),
                  width: width / dateScheme.count,
                  height: height / weekScheme.count,
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
