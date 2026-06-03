import 'package:calendar/src/const.dart';
import 'package:calendar/src/context.dart';
import 'package:calendar/src/mixin.dart';
import 'package:calendar/src/utils/datetime.dart';
import 'package:calendar/src/widgets/components/header_week.dart';
import 'package:calendar/src/widgets/pages/page_weekly.dart';
import 'package:flutter/material.dart';
import '../components/header_time.dart';
import '../frames/frame_weekly.dart';
import '../../enums.dart';
import '../../data/source.dart';


class WeeklyView extends StatefulWidget with DateScheme, TimeScheme {

  const WeeklyView({
    super.key,
    required this.week,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    // TimeHeader attributes
    required this.timeRatio,
    required this.timeFormat,
    this.timePadding,
    this.timeTextStyle,
    this.timeBackground,
    // DateHeader attributes,
    required this.dateFormat,
    this.datePadding,
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
    this.timeRound,
  });

  // TimeHeader attributes
  final Week week;
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  final double timeRatio;
  final String dateFormat;
  final String timeFormat;
  final double? datePadding;
  final double? timePadding;
  final TextStyle? dateTextStyle;
  final TextStyle? timeTextStyle;
  final Color? dateBackground;
  final Color? timeBackground;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  final int? timeRound;

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}


class _WeeklyViewState extends State<WeeklyView> {

  void onPageTap(int tappedDay, int tappedMinute) {
    Date date = widget.week.mon + tappedDay;
    Time time = Time(widget.begHour, tappedMinute);
    if (widget.timeRound != null) {
      time = time.round(widget.timeRound!);
    }
    print(date & time);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeMargin = context.timeMargin(widget.timeTextStyle);
        final timeOffset = context.timeWidth(
            widget.timeFormat, widget.timeTextStyle, widget.timePadding
        );
        final dateOffset = context.dateWidth(
            widget.dateFormat, widget.dateTextStyle, widget.datePadding
        );
        //
        final sizeHeight = (widget.timeRatio == 0)
            ? constraints.maxHeight - timeMargin - dateOffset
            : widget.minutes * widget.timeRatio;
        final sizeWidth = constraints.maxWidth - timeOffset;
        //
        final timeHeader = TimeHeader(
          begHour: widget.begHour,
          endHour: widget.endHour,
          timeStep: widget.timeStep,
          height: sizeHeight,
          timeFormat: widget.timeFormat,
          timePadding: widget.timePadding,
          timeTextStyle: widget.timeTextStyle,
          background: widget.timeBackground,
        );
        final weekHeader = WeekHeader(
          week: widget.week,
          width: sizeWidth,
          begDay: widget.begDay,
          endDay: widget.endDay,
          dateStep: widget.dateStep,
          background: widget.dateBackground,
          dateFormat: widget.dateFormat,
          datePadding: widget.datePadding,
          dateTextStyle: widget.dateTextStyle,
        );
        final weekFrame = WeeklyFrame(
          width: sizeWidth,
          height: sizeHeight,
          begDay: widget.begDay,
          endDay: widget.endDay,
          dateStep: widget.dateStep,
          begHour: widget.begHour,
          endHour: widget.endHour,
          timeStep: widget.timeStep,
          lineStyle: widget.lineStyle,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          lineOffsetX: widget.lineOffsetX - (widget.timePadding ?? 0)/2,
          lineOffsetY: widget.lineOffsetY - (widget.datePadding ?? 0)/2,
          dashedSpace: widget.dashedSpace,
          dashedWidth: widget.dashedWidth,
          weeklyTap: onPageTap,
        );
        final weekPage = WeeklyPage(
          week: widget.week,
          width: sizeWidth,
          height: sizeHeight,
          begDay: widget.begDay,
          endDay: widget.endDay,
          dateStep: widget.dateStep,
          begHour: widget.begHour,
          endHour: widget.endHour,
          timeStep: widget.timeStep,
        );
        final weekView = Row(
          children: [
            timeHeader,
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: timeMargin / 2
                ),
                child: Stack(
                    children: [
                      weekFrame,
                      weekPage,
                    ]
                ),
              ),
            ),
          ],
        );
        return Column(
          children: [
            Row(
              children: [
                SizedBox(width: timeOffset),
                weekHeader,
              ],
            ),
            Expanded(
              child: (widget.timeRatio == 0) ? weekView : SingleChildScrollView(
                child: weekView,
              ),
            )
          ],
        );
      },
    );
  }
}
