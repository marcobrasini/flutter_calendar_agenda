import 'package:flutter/material.dart';
import '../components/header_time.dart';
import '../frames/frame_weekly.dart';
import '../pages/page_weekly.dart';
import '../../utils/datetime.dart';
import '../../context.dart';
import '../../enums.dart';
import '../../mixin.dart';


class WeeklyView extends StatelessWidget with DateScheme, TimeScheme {

  const WeeklyView({
    super.key,
    required this.begDay,
    required this.endDay,
    required this.dateStep,
    required this.begHour,
    required this.endHour,
    required this.timeStep,
    // TimeHeader attributes
    required this.timeRatio,
    required this.timeFormat,
    required this.timePadding,
    this.timeTextStyle,
    this.timeBackground,
    // DateHeader attributes,
    required this.dateFormat,
    required this.datePadding,
    this.dateTextStyle,
    this.dateBackground,
    //
    required this.weeklyFormat,
    required this.weeklyPadding,
    this.weeklyTextStyle,
    this.weeklyBackground,
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
    //
    this.cornerWidget,
  });

  // TimeHeader attributes
  @override final int begDay;
  @override final int endDay;
  @override final int dateStep;
  @override final int begHour;
  @override final int endHour;
  @override final int timeStep;
  final double timeRatio;
  final String dateFormat;
  final String timeFormat;
  final String weeklyFormat;
  final double datePadding;
  final double timePadding;
  final double weeklyPadding;
  final TextStyle? dateTextStyle;
  final TextStyle? timeTextStyle;
  final TextStyle? weeklyTextStyle;
  final Color? dateBackground;
  final Color? timeBackground;
  final Color? weeklyBackground;
  // LinePainter attributes
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  final int? timeRound;
  final Widget? cornerWidget;
  

  void onPageTap(int tappedDay, int tappedMinute) {
    // Date date = week.mon + tappedDay;
    Time time = Time(begHour, tappedMinute);
    if (timeRound != null) {
      time = time.round(timeRound!);
    }
    print(time);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final timeMargin = context.timeMargin(timeTextStyle);
        final timeOffset = context.timeWidth(
            timeFormat, timeTextStyle, timePadding);
        final dateOffset = context.dateWidth(
            dateFormat, dateTextStyle, datePadding);
        //
        final pageHeight = (timeRatio == 0)
            ? constraints.maxHeight - timeMargin - dateOffset
            : minutes * timeRatio;
        final pageWidth = constraints.maxWidth - timeOffset;
        //
        final cornerFrame = SizedBox(
          width: timeOffset,
          height: dateOffset,
          child: cornerWidget,
        );
        final headerFrame = SizedBox(
          width: pageWidth,
          height: dateOffset,
        );
        final timeHeader = TimeHeader(
          width: timeOffset,
          height: pageHeight,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          timeFormat: timeFormat,
          timePadding: timePadding,
          timeTextStyle: timeTextStyle,
          background: timeBackground,
        );
        final weekFrame = WeeklyFrame(
          width: pageWidth,
          height: pageHeight,
          header: headerFrame,
          padding: timeMargin/2,
          begDay: begDay,
          endDay: endDay,
          dateStep: dateStep,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          lineStyle: lineStyle,
          lineColor: lineColor,
          lineWidth: lineWidth,
          lineOffsetX: lineOffsetX - timePadding/2,
          lineOffsetY: lineOffsetY - datePadding/2,
          dashedSpace: dashedSpace,
          dashedWidth: dashedWidth,
          weeklyTap: onPageTap,
        );
        final weekPage = WeeklyPage(
          width: pageWidth,
          height: pageHeight,
          padding: timeMargin/2,
          begDay: begDay,
          endDay: endDay,
          dateStep: dateStep,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          dateFormat: dateFormat,
          datePadding: datePadding,
          dateTextStyle: dateTextStyle,
          dateBackground: dateBackground,
        );
        final weekView = Row(
          children: [
            Column(
              children: [
                cornerFrame,
                timeHeader,
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  weekFrame,
                  weekPage,
                ]
              ),
            ),
          ],
        );
        return SingleChildScrollView(
          child: weekView,
        );
      },
    );
  }
}
