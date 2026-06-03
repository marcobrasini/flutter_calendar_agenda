import 'package:calendar/src/const.dart';
import 'package:calendar/src/data/event.dart';
import 'package:calendar/src/data/source.dart';
import 'package:calendar/src/mixin.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/slot_date.dart';
import 'package:calendar/src/widgets/components/slot_event.dart';
import 'package:calendar/src/widgets/pages/slot_page.dart';
import 'package:flutter/material.dart';


class MonthlyPage extends StatefulWidget with WeekScheme, DateScheme {

  const MonthlyPage({
    super.key,
    required this.month,
    required this.width,
    required this.height,
    required this.begWeek,
    required this.endWeek,
    required this.weekStep,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    required this.dateFormat,
    required this.datePadding,
    this.dateTextStyle,
    this.background,
  });

  final Month month;
  final double width;
  final double height;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  double get dayScale => days / width;
  @override final int begWeek;
  @override final int endWeek;
  @override final int weekStep;
  double get weekScale => weeks / height;
  final String dateFormat;
  final double datePadding;
  final TextStyle? dateTextStyle;
  final Color? background;

  Date get startDate => month.weekStart.date;

  @override
  State<MonthlyPage> createState() => _MonthlyPageState();
}


class _MonthlyPageState extends State<MonthlyPage> {

  int x(Event event) => event.start.weekday - widget.begDay;
  int y(Event event) => event.start.date % widget.month.weekStart ~/ stepWeek;

  bool isCurrent(Date date) => date.month != widget.month.month;

  @override
  Widget build(BuildContext context) {
    final slotPainter = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < widget.weeks; i++)
          Row(
            children: [
              for (int j = 0; j < widget.days; j++)
                DateSlot(
                  width: widget.width / widget.days,
                  height: widget.height / widget.weeks,
                  date: widget.startDate + (i * stepWeek + j) + (widget.begDay - 1),
                  dateFormat: widget.dateFormat,
                  datePadding: widget.datePadding,
                  dateTextStyle: widget.dateTextStyle,
                  dateBackground: widget.background,
                  dateWidget: PageSlot(
                    date: widget.startDate + (i * stepWeek + j) + (widget.begDay - 1),
                  ),
                ),
            ],
          )
      ],
    );
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: slotPainter,
    );
  }
}
