import 'package:calendar/src/const.dart';
import 'package:flutter/material.dart';
import 'widgets/views/view_daily.dart';
import 'widgets/views/view_weekly.dart';
import 'widgets/views/view_monthly.dart';
import 'widgets/components/header_calendar.dart';
import 'utils/datetime.dart';
import 'data/source.dart';
import 'enums.dart';


class Calendar extends StatelessWidget {
  final CalendarView view;
  final Source source;
  final int begHour;
  final int endHour;
  final int timeStep;
  final int begDay;
  final int endDay;
  final int dateStep;
  final int begWeek;
  final int endWeek;
  final int weekStep;
  //
  final double timeRatio;
  final String timeFormat;
  final double timePadding;
  final TextStyle? timeTextStyle;
  final Color? timeBackground;
  //
  final String dateFormat;
  final double datePadding;
  final TextStyle? dateTextStyle;
  final Color? dateBackground;
  //
  final String dailyFormat;
  final double dailyPadding;
  final TextStyle? dailyTextStyle;
  final Color? dailyBackground;
  //
  final String weeklyFormat;
  final double weeklyPadding;
  final TextStyle? weeklyTextStyle;
  final Color? weeklyBackground;
  //
  final String dayFormat;
  final String weekFormat;
  final double weekPadding;
  final TextStyle? weekTextStyle;
  final Color? weekBackground;
  //
  final LineStyle lineStyle;
  final Color lineColor;
  final double lineWidth;
  final double lineOffsetX;
  final double lineOffsetY;
  final double? dashedWidth;
  final double? dashedSpace;
  //
  final TextStyle? headerTextStyle;

  const Calendar({
    super.key,
    required this.view,
    required this.source,
    this.begHour = initialHour,
    this.endHour = finalHour,
    this.timeStep = stepHour,
    this.begDay = initialDay,
    this.endDay = finalDay,
    this.dateStep = stepDay,
    this.begWeek = initialWeek,
    this.endWeek = finalWeek,
    this.weekStep = stepWeek,
    //
    this.timeRatio = timeHeaderRatio,
    this.timeFormat = timeHeaderFormat,
    this.timePadding = timeHeaderPadding,
    this.timeTextStyle,
    this.timeBackground,
    //
    this.dateFormat = dateHeaderFormat,
    this.datePadding = dateHeaderPadding,
    this.dateTextStyle,
    this.dateBackground,
    //
    this.dailyFormat = dailyHeaderFormat,
    this.dailyPadding = dailyHeaderPadding,
    this.dailyTextStyle,
    this.dailyBackground,
    //
    this.weeklyFormat = weeklyHeaderFormat,
    this.weeklyPadding = weeklyHeaderPadding,
    this.weeklyTextStyle,
    this.weeklyBackground,
    //
    this.dayFormat = dayHeaderFormat,
    this.weekFormat = weekHeaderFormat,
    this.weekPadding = textHeaderPadding,
    this.weekTextStyle,
    this.weekBackground,
    //
    this.lineStyle = lineFrameStyle,
    this.lineColor = lineFrameColor,
    this.lineWidth = lineFrameWidth,
    this.lineOffsetX = lineFrameOffsetX,
    this.lineOffsetY = lineFrameOffsetY,
    this.dashedWidth,
    this.dashedSpace,
    //
    this.headerTextStyle,
  });

  Widget get page {
    switch (view) {
      case CalendarView.daily:
        return DailyView(
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          timeRatio: timeRatio,
          timeFormat: timeFormat,
          timePadding: timePadding,
          dailyFormat: dailyFormat,
          dailyPadding: dailyPadding,
          dailyTextStyle: dailyTextStyle,
          dailyBackground: dailyBackground,
          lineStyle: lineStyle,
          lineColor: lineColor,
          lineWidth: lineWidth,
          lineOffset: lineOffsetX,
          dashedWidth: dashedWidth,
          dashedSpace: dashedSpace,
        );
      case CalendarView.weekly:
        return WeeklyView(
          begDay: begDay,
          endDay: endDay,
          dateStep: dateStep,
          begHour: begHour,
          endHour: endHour,
          timeStep: timeStep,
          timeRatio: timeRatio,
          timeFormat: timeFormat,
          timePadding: timePadding,
          timeTextStyle: timeTextStyle,
          timeBackground: timeBackground,
          dateFormat: dateFormat,
          datePadding: datePadding,
          dateTextStyle: dateTextStyle,
          dateBackground: dateBackground,
          weeklyFormat: weeklyFormat,
          weeklyPadding: weeklyPadding,
          weeklyTextStyle: weeklyTextStyle,
          weeklyBackground: weeklyBackground,
          lineStyle: lineStyle,
          lineColor: lineColor,
          lineWidth: lineWidth,
          lineOffsetX: lineOffsetX,
          lineOffsetY: lineOffsetY,
          dashedWidth: dashedWidth,
          dashedSpace: dashedSpace,
        );
      case CalendarView.monthly:
        return Placeholder();
        // return MonthlyView(
        //   begWeek: begWeek,
        //   endWeek: endWeek,
        //   weekStep: weekStep,
        //   begDay: begDay,
        //   endDay: endDay,
        //   dateStep: dateStep,
        //   weekFormat: weekFormat,
        //   weekPadding: weekPadding,
        //   weekTextStyle: weekTextStyle,
        //   weekBackground: weekBackground,
        //   dateFormat: dayFormat,
        //   datePadding: datePadding,
        //   dateTextStyle: dateTextStyle,
        //   dateBackground: dateBackground,
        //   lineColor: lineColor,
        //   lineStyle: lineStyle,
        //   lineWidth: lineWidth,
        //   lineOffsetX: lineOffsetX,
        //   lineOffsetY: lineOffsetY,
        //   dashedWidth: dashedWidth,
        //   dashedSpace: dashedSpace,
        // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalendarSource(
      source: source,
      child: page,
    );
  }
}
