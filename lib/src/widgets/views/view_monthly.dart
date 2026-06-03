import 'package:calendar/src/const.dart';
import 'package:calendar/src/context.dart';
import 'package:calendar/src/mixin.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/header_month.dart';
import 'package:calendar/src/widgets/pages/page_monthly.dart';
import 'package:flutter/material.dart';
import '../frames/frame_monthly.dart';
import '../../enums.dart';
import '../../data/source.dart';


class MonthlyView extends StatefulWidget with WeekScheme, DateScheme {

  const MonthlyView({
    super.key,
    required this.begWeek,
    required this.endWeek,
    required this.weekStep,
    required this.month,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    // WeekHEader attributes
    required this.weekFormat,
    required this.weekPadding,
    this.weekTextStyle,
    this.weekBackground,
    // DateHeader attributes
    required this.dateFormat,
    required this.datePadding,
    this.dateTextStyle,
    this.dateBackground,
    // LinePainter attributes
    required this.lineColor,
    required this.lineStyle,
    required this.lineWidth,
    required this.lineOffsetX,
    required this.lineOffsetY,
    this.dashedWidth,
    this.dashedSpace,
    // Interactive callback
  });

  // TimeHeader attributes
  final Month month;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  @override final int begWeek;
  @override final int endWeek;
  @override final int weekStep;
  final String weekFormat;
  final String dateFormat;
  final double weekPadding;
  final double datePadding;
  final TextStyle? weekTextStyle;
  final TextStyle? dateTextStyle;
  final Color? weekBackground;
  final Color? dateBackground;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}


class _MonthlyViewState extends State<MonthlyView> {

  void onPageTap(int tappedWeek, int tappedDay) {
    print("$tappedWeek $tappedDay");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final source = CalendarSource.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final dayOffset = context.dateWidth(
            widget.dateFormat, widget.dateTextStyle, widget.datePadding);
        // final weekSlots = weekMonthSlots;
        final sizeHeight = constraints.maxHeight - dayOffset;
        final sizeWidth = constraints.maxWidth;
        final monthHeader = MonthHeader(
          month: widget.month,
          width: sizeWidth,
          begDay: widget.begDay,
          endDay: widget.endDay,
          dateStep: widget.dateStep,
          background: widget.dateBackground,
          weekFormat: widget.weekFormat,
          weekPadding: widget.datePadding,
          weekTextStyle: widget.dateTextStyle,
        );
        final monthFrame = MonthlyFrame(
          width: sizeWidth,
          height: sizeHeight,
          begWeek: widget.begWeek,
          endWeek: widget.endWeek,
          weekStep: widget.weekStep,
          begDay: widget.begDay,
          endDay: widget.endDay,
          dateStep: widget.dateStep,
          lineStyle: widget.lineStyle,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          lineOffsetX: widget.lineOffsetX - widget.weekPadding/2,
          lineOffsetY: widget.lineOffsetY - widget.datePadding/2,
          dashedSpace: widget.dashedSpace,
          dashedWidth: widget.dashedWidth,
          monthlyTap: onPageTap,
        );
        final monthPage = MonthlyPage(
          month: widget.month,
          width: sizeWidth,
          height: sizeHeight,
          begWeek: widget.begWeek,
          endWeek: widget.endWeek,
          weekStep: widget.weekStep,
          begDay: widget.begDay,
          endDay: widget.endDay,
          dateStep: widget.dateStep,
          dateFormat: widget.dateFormat,
          datePadding: widget.datePadding,
          dateTextStyle: widget.dateTextStyle,
        );
        return Column(
          children: [
            monthHeader,
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                    children: [
                      monthFrame,
                      monthPage,
                    ]
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

